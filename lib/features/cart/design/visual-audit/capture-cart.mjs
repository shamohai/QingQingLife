import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const [widthArg = '440', heightArg = '900', outputPrefix = 'cart-440'] = process.argv.slice(2);
const width = Number(widthArg);
const height = Number(heightArg);
const outputDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), 'output');
fs.mkdirSync(outputDir, { recursive: true });

const targetResponse = await fetch(
  `http://127.0.0.1:9223/json/new?${encodeURIComponent('http://127.0.0.1:8091/#/cart')}`,
  { method: 'PUT' },
);
if (!targetResponse.ok) throw new Error(`Unable to create Chrome target: ${targetResponse.status}`);
const target = await targetResponse.json();

const socket = new WebSocket(target.webSocketDebuggerUrl);
await new Promise((resolve, reject) => {
  socket.addEventListener('open', resolve, { once: true });
  socket.addEventListener('error', reject, { once: true });
});

let sequence = 0;
const pending = new Map();
socket.addEventListener('message', (event) => {
  const message = JSON.parse(event.data);
  if (!message.id) return;
  const callback = pending.get(message.id);
  if (!callback) return;
  pending.delete(message.id);
  if (message.error) callback.reject(new Error(message.error.message));
  else callback.resolve(message.result);
});

function command(method, params = {}) {
  const id = ++sequence;
  socket.send(JSON.stringify({ id, method, params }));
  return new Promise((resolve, reject) => pending.set(id, { resolve, reject }));
}

const delay = (milliseconds) => new Promise((resolve) => setTimeout(resolve, milliseconds));

await command('Page.enable');
await command('Runtime.enable');
await command('Emulation.setDeviceMetricsOverride', {
  width,
  height,
  deviceScaleFactor: 1,
  mobile: false,
  screenWidth: width,
  screenHeight: height,
});
await command('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });
await command('Page.navigate', { url: 'http://127.0.0.1:8091/#/cart' });
await delay(9000);

const metricsExpression = `JSON.stringify({
  location: location.href,
  innerWidth,
  innerHeight,
  devicePixelRatio,
  documentClientWidth: document.documentElement.clientWidth,
  documentScrollWidth: document.documentElement.scrollWidth,
  documentScrollHeight: document.documentElement.scrollHeight,
  bodyClientWidth: document.body.clientWidth,
  bodyScrollWidth: document.body.scrollWidth,
  bodyScrollHeight: document.body.scrollHeight
})`;
const metricsResult = await command('Runtime.evaluate', {
  expression: metricsExpression,
  returnByValue: true,
});
const metrics = JSON.parse(metricsResult.result.value);

async function capture(name) {
  const result = await command('Page.captureScreenshot', {
    format: 'png',
    fromSurface: true,
    captureBeyondViewport: false,
  });
  fs.writeFileSync(path.join(outputDir, `${outputPrefix}-${name}.png`), Buffer.from(result.data, 'base64'));
}

await capture('initial');
await command('Input.dispatchMouseEvent', {
  type: 'mouseWheel',
  x: Math.round(width / 2),
  y: Math.round(height * 0.72),
  deltaX: 0,
  deltaY: 720,
});
await delay(1800);
await capture('scrolled');

const report = {
  viewport: { width, height },
  metrics,
  screenshots: [`${outputPrefix}-initial.png`, `${outputPrefix}-scrolled.png`],
};
fs.writeFileSync(
  path.join(outputDir, `${outputPrefix}-metrics.json`),
  `${JSON.stringify(report, null, 2)}\n`,
);
console.log(JSON.stringify(report));

socket.close();
