class ServiceItem {
  final String id;
  final String name;
  final String status; // 'ongoing' | 'ended' | 'upcoming' | 'record'

  const ServiceItem({
    required this.id,
    required this.name,
    this.status = 'ongoing',
  });

  static const List<ServiceItem> staticList = [
    ServiceItem(id: '1', name: '高尔夫', status: 'ongoing'),
    ServiceItem(id: '2', name: '跑步', status: 'ongoing'),
    ServiceItem(id: '3', name: '自行车', status: 'ongoing'),
    ServiceItem(id: '4', name: '露营', status: 'ongoing'),
    ServiceItem(id: '5', name: '网羽中心', status: 'ongoing'),
    ServiceItem(id: '6', name: '天佑德挚友会', status: 'ongoing'),
  ];
}
