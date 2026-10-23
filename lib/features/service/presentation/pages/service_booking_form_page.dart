import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/router/route_names.dart';
import '../../domain/models/reservation_service_detail_model.dart';
import '../../data/datasources/service_remote_datasource.dart';
import '../widgets/booking_form_field.dart';

/// 预约项目填写信息页面
///
/// 路由: /service/project/:id/book
/// 进入方式: 从预约项目详情页点击「立即预约/报名」按钮跳转
/// 接收完整的 ReservationServiceDetail 对象
class ServiceBookingFormPage extends ConsumerStatefulWidget {
  final ReservationServiceDetail detail;

  const ServiceBookingFormPage({super.key, required this.detail});

  @override
  ConsumerState<ServiceBookingFormPage> createState() => _ServiceBookingFormPageState();
}

class _ServiceBookingFormPageState extends ConsumerState<ServiceBookingFormPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _idCtrl;
  late final TextEditingController _partyCtrl;
  late final TextEditingController _notesCtrl;

  bool _isSubmitting = false;
  bool _isAlreadyReserved = false;

  DateTime? _selectedDate;
  Map<String, dynamic>? _selectedTimeSlotObj;

  // 从 calendar 解析出的可选日期列表
  List<DateTime> _availableDates = [];
  // 当前选中日期对应的时段列表（完整对象）
  List<Map<String, dynamic>> _availableTimeSlotObjects = [];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _idCtrl = TextEditingController();
    _partyCtrl = TextEditingController();
    _notesCtrl = TextEditingController();

    _parseCalendar();
    _checkAndPopulateReservation();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _idCtrl.dispose();
    _partyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ─── 解析 calendar ──────────────────────────────────────────────────

  /// 解析 calendar 数据，提取可选日期和时段
  /// calendar 结构：List<{date: String, timeslots: List<{starttime, endtime, fullstarttiime}>>}
  void _parseCalendar() {
    final calendar = widget.detail.calendar;
    if (calendar == null) return;

    try {
      if (calendar is List) {
        for (final item in calendar) {
          if (item is Map) {
            final dateStr = item['date'] as String?;
            if (dateStr != null) {
              final parsed = DateTime.tryParse(dateStr);
              if (parsed != null) _availableDates.add(parsed);
            }
          }
        }
      }
      _availableDates.sort((a, b) => a.compareTo(b));
    } catch (_) {
      // 解析失败时忽略，使用默认日期选择器
    }
  }

  /// 检查是否已报名，如果已报名则填充表单并禁用
  void _checkAndPopulateReservation() {
    final myInfo = widget.detail.myReservationInfo;
    if (myInfo != null) {
      _isAlreadyReserved = true;
      // 字段名对应 API 返回的 myreservationinfo 结构：
      // contactname, contactphonenumber, idno, usercount, reservationdate, reservationtime, remark
      _nameCtrl.text = myInfo['contactname'] as String? ?? '';
      _phoneCtrl.text = myInfo['contactphonenumber'] as String? ?? '';
      _idCtrl.text = myInfo['idno'] as String? ?? '';
      _partyCtrl.text = (myInfo['usercount'] as num?)?.toString() ?? '';
      _notesCtrl.text = myInfo['remark'] as String? ?? '';

      // 解析已选日期和时段
      final dateStr = myInfo['reservationdate'] as String?;
      if (dateStr != null) {
        _selectedDate = DateTime.tryParse(dateStr);
      }
      final timeSlot = myInfo['reservationtime'] as String?;

      // 同步解析该日期的时段列表，并匹配已选时段
      if (_selectedDate != null) {
        _updateTimeSlotsForDate(_selectedDate!);
        // 匹配已选时段
        if (timeSlot != null && _availableTimeSlotObjects.isNotEmpty) {
          try {
            final matched = _availableTimeSlotObjects.firstWhere(
              (s) => s['timedescr'] == timeSlot || s['fullstarttiime'] == timeSlot,
              orElse: () => <String, dynamic>{},
            );
            if (matched.isNotEmpty) {
              _selectedTimeSlotObj = matched;
            }
          } catch (_) {}
          // 触发 UI 更新
          if (mounted) setState(() {});
        }
      }
    }
  }

  /// 根据选中的日期更新可用时段列表
  void _updateTimeSlotsForDate(DateTime date) {
    final calendar = widget.detail.calendar;
    if (calendar == null) return;

      try {
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        List<Map<String, dynamic>> slotObjects = [];

        if (calendar is List) {
          for (final item in calendar) {
            if (item is Map) {
              final itemDate = item['date'] as String?;
              if (itemDate == dateKey) {
                final timeslots = item['timeslots'] as List<dynamic>? ?? [];
                for (final slot in timeslots) {
                  if (slot is Map) {
                    final start = slot['starttime'] as String? ?? '';
                    final end = slot['endtime'] as String? ?? '';
                    final fullStart = slot['fullstarttiime'] as String? ?? '';
                    final timedescr = slot['timedescr'] as String? ?? '';
                    if (start.isNotEmpty && end.isNotEmpty) {
                      slotObjects.add({
                        'timedescr': timedescr,
                        'starttime': start,
                        'endtime': end,
                        'fullstarttiime': fullStart,
                      });
                    }
                  }
                }
                break; // 找到匹配日期后停止
              }
            }
          }
        } else if (calendar is Map) {
          // 兼容 Map 格式
          final dates = calendar['dates'] as List<dynamic>? ?? [];
          for (final dateStr in dates) {
            if (dateStr == dateKey) {
              final slotsMap = calendar['slots'] as Map<String, dynamic>? ?? {};
              final daySlots = slotsMap[dateKey] as List<dynamic>? ?? [];
              for (final slot in daySlots) {
                if (slot is String) {
                  slotObjects.add({'timedescr': slot});
                }
              }
              break;
            }
          }
        }

        if (mounted) {
          setState(() {
            _availableTimeSlotObjects = slotObjects;
            // 如果当前选中的时段不在新列表中，清空选择
            if (_selectedTimeSlotObj != null) {
              final stillExists = slotObjects.any((s) => s['timedescr'] == _selectedTimeSlotObj!['timedescr']);
              if (!stillExists) {
                _selectedTimeSlotObj = null;
              }
            }
          });
        }
      } catch (_) {}
    }

  // ─── 验证 ────────────────────────────────────────────────────────────

  static final RegExp _phoneRegex = RegExp(r'^1\d{10}$');
  static final RegExp _idCardRegex = RegExp(r'^\d{17}[\dXx]$');

  String? _validateName() {
    final v = _nameCtrl.text.trim();
    if (v.isEmpty) return '请输入联系人姓名';
    return null;
  }

  String? _validatePhone() {
    final v = _phoneCtrl.text.trim();
    if (v.isEmpty) return '请输入联系电话';
    if (!_phoneRegex.hasMatch(v)) return '请输入正确的联系电话';
    return null;
  }

  String? _validateIdCard() {
    final v = _idCtrl.text.trim();
    if (v.isEmpty) return null;
    if (!_idCardRegex.hasMatch(v.toUpperCase())) return '请输入正确的身份证号码';
    return null;
  }

  String? _validatePartySize() {
    final v = _partyCtrl.text.trim();
    if (v.isEmpty) return null;
    final n = int.tryParse(v);
    if (n == null || n < 1 || n > 999) return '请输入正确的预约人数';
    return null;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  Future<void> _openDatePicker() async {
    if (_isAlreadyReserved) return;

    DateTime initialDate = _selectedDate ?? DateTime.now();
    DateTime firstDate = DateTime.now();
    DateTime lastDate = DateTime.now().add(const Duration(days: 365));

    // 如果有可用日期列表，限制选择范围
    if (_availableDates.isNotEmpty) {
      firstDate = _availableDates.first.isAfter(firstDate) ? _availableDates.first : firstDate;
      lastDate = _availableDates.last.isBefore(lastDate) ? _availableDates.last : lastDate;
      if (initialDate.isBefore(firstDate)) initialDate = firstDate;
      if (initialDate.isAfter(lastDate)) initialDate = lastDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: _availableDates.isNotEmpty
          ? (day) => _availableDates.any((d) => d.year == day.year && d.month == day.month && d.day == day.day)
          : null,
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlotObj = null;
      });
      _updateTimeSlotsForDate(picked);
    }
  }

  Future<void> _openTimeSlotPicker() async {
    if (_isAlreadyReserved) return;
    if (_selectedDate == null) {
      _showError('请先选择预约日期');
      return;
    }
    if (_availableTimeSlotObjects.isEmpty) {
      _showError('该日期暂无可用时段');
      return;
    }

    final picked = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _TimeSlotPickerSheet(slots: _availableTimeSlotObjects, current: _selectedTimeSlotObj),
    );

    if (picked != null && mounted) {
      setState(() => _selectedTimeSlotObj = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (_isAlreadyReserved) return;

    final nameError = _validateName();
    if (nameError != null) {
      _showError(nameError);
      return;
    }
    final phoneError = _validatePhone();
    if (phoneError != null) {
      _showError(phoneError);
      return;
    }
    final idError = _validateIdCard();
    if (idError != null) {
      _showError(idError);
      return;
    }
    final partyError = _validatePartySize();
    if (partyError != null) {
      _showError(partyError);
      return;
    }
    if (_selectedDate == null) {
      _showError('请选择预约日期');
      return;
    }
    if (_selectedTimeSlotObj == null) {
      _showError('请选择预约时段');
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = true);

    // reservationdatetime: 使用 fullstarttiime
    final fullStartTime = _selectedTimeSlotObj?['fullstarttiime'] as String? ?? '';
    final reservationDateTime = fullStartTime.isNotEmpty ? fullStartTime : DateFormat('yyyy-MM-dd').format(_selectedDate!);

    try {
          final dataSource = ref.read(serviceRemoteDataSourceProvider);
          final response = await dataSource.submitReservation(
            serviceId: widget.detail.serviceId,
            contactName: _nameCtrl.text.trim(),
            contactPhoneNumber: _phoneCtrl.text.trim(),
            reservationDateTime: reservationDateTime,
            idNo: _idCtrl.text.trim(),
            userCount: int.parse(_partyCtrl.text.trim()),
            remark: _notesCtrl.text.trim(),
          );
          response.requireData;

          if (!mounted) return;
          setState(() {
            _isSubmitting = false;
            _isAlreadyReserved = true; // 提交成功后设为已报名状态，表单变只读
          });

          // 显示成功弹窗
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('报名成功', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              content: const Text('您的报名信息已提交成功', style: TextStyle(fontSize: 14, color: Color(0xFF333333))),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(); // 关闭弹窗
                    context.go(RouteNames.service); // 跳转到服务预约列表页
                  },
                  child: const Text('确定', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.serviceTabActive)),
                ),
              ],
            ),
          );
        } catch (_) {
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('提交失败，请稍后重试'), behavior: SnackBarBehavior.floating));
        }
      }

  // ─── UI ──────────────────────────────────────────────────────────────

  Widget _buildValueText(String text, [Color? color]) {
    return Text(
      text,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: color ?? const Color(0xFF8E8E93)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, {TextInputType? keyboardType, int? maxLength, String? hintText, bool enabled = true}) {
    // 已报名时使用 readOnly 而非 enabled=false，确保文字可见且不可编辑
    final isReadOnly = !enabled;
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLength: maxLength,
      readOnly: isReadOnly,
      enabled: enabled,
      inputFormatters: keyboardType == TextInputType.phone
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), LengthLimitingTextInputFormatter(maxLength ?? 11)]
          : keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), LengthLimitingTextInputFormatter(maxLength ?? 3)]
          : [],
      style: TextStyle(fontSize: 16, color: enabled ? Colors.black : const Color(0xFF333333)),
      decoration: InputDecoration(
        isDense: true,
        counterText: '',
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: hintText ?? '',
        hintStyle: const TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
        contentPadding: EdgeInsets.zero,
        filled: !enabled,
        fillColor: !enabled ? const Color(0xFFF5F5F5) : null,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, {String? title}) {
    return AppBar(
      backgroundColor: AppColors.servicePageBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(title ?? '报名信息', style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, color: Colors.black)),
      centerTitle: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final headImgUrl = detail.headImgUrl;

    return Scaffold(
      backgroundColor: AppColors.servicePageBackground,
      appBar: _buildAppBar(context, title: detail.serviceName),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    // 头图：使用 detail.headImgUrl
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
                          child: AspectRatio(
                            aspectRatio: 412 / 180,
                            child: headImgUrl.startsWith('http')
                                ? Image.network(headImgUrl, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _defaultHeroImage())
                                : headImgUrl.isNotEmpty
                                ? Image.asset(headImgUrl, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _defaultHeroImage())
                                : _defaultHeroImage(),
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -50),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
                            boxShadow: const [BoxShadow(color: Color(0xFFE6E8E9), blurRadius: 7, offset: Offset(0, 2))],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 已报名提示
                              if (_isAlreadyReserved) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                                  child: const Text(
                                    '您已报名该项目，不可重复报名',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF999999)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Field 1: 联系人
                              BookingFormField(
                                label: '联系人',
                                imageAsset: 'assets/images/service/service_booking_name.png',
                                valueWidget: _buildTextField(_nameCtrl, maxLength: 30, hintText: '请输入联系人姓名', enabled: !_isAlreadyReserved),
                              ),

                              // Field 2: 联系电话
                              BookingFormField(
                                label: '联系电话',
                                imageAsset: 'assets/images/service/service_booking_phone.png',
                                valueWidget: _buildTextField(_phoneCtrl, keyboardType: TextInputType.phone, maxLength: 11, hintText: '请输入联系电话', enabled: !_isAlreadyReserved),
                              ),

                              // Field 3: 身份证号码
                              BookingFormField(
                                label: '身份证号码',
                                imageAsset: 'assets/images/service/service_booking_idcard.png',
                                valueWidget: _buildTextField(_idCtrl, maxLength: 18, hintText: '请输入身份证号码', enabled: !_isAlreadyReserved),
                              ),

                              // Field 4: 预约人数
                              BookingFormField(
                                label: '预约人数',
                                imageAsset: 'assets/images/service/service_booking_count.png',
                                valueWidget: _buildTextField(_partyCtrl, keyboardType: TextInputType.number, maxLength: 3, hintText: '请输入预约人数', enabled: !_isAlreadyReserved),
                              ),

                              // Field 5: 预约日期
                              BookingFormField(
                                label: '预约日期',
                                imageAsset: 'assets/images/service/service_booking_date.png',
                                valueWidget: _selectedDate == null
                                    ? _buildValueText('请选择预约日期')
                                    : _buildValueText(DateFormat('yyyy-MM-dd').format(_selectedDate!), Colors.black),
                                showChevron: !_isAlreadyReserved,
                                onTap: _isAlreadyReserved ? null : _openDatePicker,
                              ),

                              // Field 6: 预约时段
                              BookingFormField(
                                label: '预约时段',
                                imageAsset: 'assets/images/service/service_booking_time.png',
                                valueWidget: _selectedTimeSlotObj == null
                                    ? _buildValueText('请选择预约时段')
                                    : _buildValueText(_selectedTimeSlotObj!['timedescr'] as String, Colors.black),
                                showChevron: !_isAlreadyReserved,
                                onTap: _isAlreadyReserved ? null : _openTimeSlotPicker,
                              ),

                              const SizedBox(height: 16),

                              // Notes
                              const Text(
                                '备注',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF213775)),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 140,
                                decoration: BoxDecoration(
                                  color: _isAlreadyReserved ? const Color(0xFFF5F5F5) : const Color(0xFFF3F5F7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: TextField(
                                  controller: _notesCtrl,
                                  maxLines: 5,
                                  readOnly: _isAlreadyReserved,
                                  enabled: !_isAlreadyReserved,
                                  style: TextStyle(fontSize: 16, color: _isAlreadyReserved ? const Color(0xFF333333) : Colors.black),
                                  decoration: const InputDecoration(
                                    hintText: '请输入备注信息',
                                    hintStyle: TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    filled: false,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // 固定底部提交按钮
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(30, AppSpacing.md, 30, AppSpacing.lg),
          child: GestureDetector(
            onTap: (_isSubmitting || _isAlreadyReserved) ? null : _handleSubmit,
            child: Container(
              width: double.infinity,
              height: 51,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.round),
                gradient: _isAlreadyReserved
                    ? null
                    : const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [AppColors.serviceCtaGradStart, AppColors.serviceTabActive],
                      ),
                color: _isAlreadyReserved ? AppColors.serviceButtonDisabled : null,
              ),
              child: Center(
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        _isAlreadyReserved ? '已报名' : '提交报名',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: _isAlreadyReserved ? AppColors.serviceButtonDisabledText : Colors.white,
                          height: 1.5,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _defaultHeroImage() {
    return Image.asset('assets/images/service/service_project_hero.png', width: double.infinity, fit: BoxFit.cover);
  }
}

/// 时段选择底部弹窗
class _TimeSlotPickerSheet extends StatelessWidget {
  final List<Map<String, dynamic>> slots;
  final Map<String, dynamic>? current;

  const _TimeSlotPickerSheet({required this.slots, this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Text(
            '选择预约时段',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: slots.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final slot = slots[index];
                final timedescr = slot['timedescr'] as String? ?? '';
                final isSelected = current != null && current!['timedescr'] == timedescr;
                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(slot),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE8EDFF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppColors.serviceTabActive : const Color(0xFFE0E0E0)),
                    ),
                    child: Text(
                      timedescr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? AppColors.serviceTabActive : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}