import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/session.dart';
import '../../models/machine.dart';
import '../../services/database_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _db = DatabaseService.instance;
  List<Session> _activeSessions = [];
  List<Machine> _machines = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final activeSessions = await _db.getActiveSessions();
    final machines = await _db.getAllMachines();

    setState(() {
      _activeSessions = activeSessions;
      _machines = machines;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.04;
    final spacing = size.height * 0.03;
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: EdgeInsets.all(padding),
        children: [
          _buildStatusCards(size),
          SizedBox(height: spacing),
          _buildActiveSessionsList(size),
          SizedBox(height: spacing),
          _buildMachineStatusChart(size),
        ],
      ),
    );
  }

  Widget _buildStatusCards(Size size) {
    final activeCount = _activeSessions.length;
    final availableMachines = _machines
        .where((m) => m.status == MachineStatus.available)
        .length;
    final maintenanceMachines = _machines
        .where((m) => m.status == MachineStatus.maintenance)
        .length;
    final cardSpacing = size.width * 0.04;
    final cardHeight = size.height * 0.18;
    final iconSize = size.width * 0.09;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: cardSpacing,
          runSpacing: cardSpacing,
          children: [
            _buildStatusCard(
              'Active Sessions',
              activeCount.toString(),
              Icons.timer,
              Colors.blue,
              cardHeight,
              iconSize,
            ),
            _buildStatusCard(
              'Available Machines',
              availableMachines.toString(),
              Icons.computer,
              Colors.green,
              cardHeight,
              iconSize,
            ),
            _buildStatusCard(
              "Today's Revenue",
              '\$${_calculateTodayRevenue().toStringAsFixed(2)}',
              Icons.attach_money,
              Colors.orange,
              cardHeight,
              iconSize,
            ),
            _buildStatusCard(
              'In Maintenance',
              maintenanceMachines.toString(),
              Icons.build,
              Colors.red,
              cardHeight,
              iconSize,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusCard(
    String title,
    String value,
    IconData icon,
    Color color,
    double height,
    double iconSize,
  ) {
    return SizedBox(
      width: height * 1.1,
      height: height,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(height * 0.13),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: color),
              SizedBox(height: height * 0.12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * 0.07),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSessionsList(Size size) {
    final padding = size.width * 0.04;
    final titleFont = Theme.of(context).textTheme.titleLarge;
    if (_activeSessions.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: const Text('No active sessions'),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(padding),
            child: Text('Active Sessions', style: titleFont),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _activeSessions.length,
            itemBuilder: (context, index) {
              final session = _activeSessions[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: size.width * 0.045,
                  child: const Icon(Icons.person),
                ),
                title: FutureBuilder(
                  future: _db.getCustomer(session.customerId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data!.name);
                    }
                    return const Text('Loading...');
                  },
                ),
                subtitle: Text(
                  'Started: ${_formatDateTime(session.startTime)}',
                ),
                trailing: Text(
                  '\$${session.currentAmount.toStringAsFixed(2)}',
                  style: titleFont?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.045,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMachineStatusChart(Size size) {
    final available = _machines
        .where((m) => m.status == MachineStatus.available)
        .length;
    final inUse = _machines
        .where((m) => m.status == MachineStatus.inUse)
        .length;
    final maintenance = _machines
        .where((m) => m.status == MachineStatus.maintenance)
        .length;
    final padding = size.width * 0.04;
    final chartHeight = size.height * 0.25;
    final chartRadius = size.width * 0.13;
    final centerRadius = size.width * 0.09;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Machine Status Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: padding),
            SizedBox(
              height: chartHeight,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: available.toDouble(),
                      title: 'Available',
                      radius: chartRadius,
                    ),
                    PieChartSectionData(
                      color: Colors.blue,
                      value: inUse.toDouble(),
                      title: 'In Use',
                      radius: chartRadius,
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: maintenance.toDouble(),
                      title: 'Maintenance',
                      radius: chartRadius,
                    ),
                  ],
                  sectionsSpace: 0,
                  centerSpaceRadius: centerRadius,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTodayRevenue() {
    // In a real app, this would query the database for completed sessions
    // from today and sum their finalAmount
    return 0.0;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
