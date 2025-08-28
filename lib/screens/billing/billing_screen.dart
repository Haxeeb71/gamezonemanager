import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/session.dart';
import '../../models/customer.dart';
import '../../models/machine.dart';
import '../../services/database_service.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final DatabaseService _db = DatabaseService.instance;
  List<Session> _sessions = [];
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    // TODO: Add method to get sessions by date range
    final sessions = await _db.getActiveSessions();
    setState(() {
      _sessions = sessions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).size.width * 0.04;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Active Sessions'),
                Tab(text: 'History'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: _buildActiveSessionsTab(),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: _buildHistoryTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessionsTab() {
    final activeSessions = _sessions.where((s) => s.endTime == null).toList();

    if (activeSessions.isEmpty) {
      return const Center(child: Text('No active sessions'));
    }

    return ListView.builder(
      itemCount: activeSessions.length,
      itemBuilder: (context, index) {
        final session = activeSessions[index];
        return FutureBuilder(
          future: Future.wait([
            _db.getCustomer(session.customerId),
            _db.getMachine(session.machineId),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const ListTile(title: Text('Loading...'));
            }

            final customer = snapshot.data![0] as Customer?;
            final machine = snapshot.data![1] as Machine?;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          customer?.name ?? 'Unknown Customer',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '\$${session.currentAmount.toStringAsFixed(2)}',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      machine?.name ?? 'Unknown Machine',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Started: ${DateFormat.yMd().add_jm().format(session.startTime)}',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _showEndSessionDialog(session),
                          child: const Text('End Session'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: DateTimeRange(
                        start: _startDate,
                        end: _endDate,
                      ),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked.start;
                        _endDate = picked.end;
                      });
                      _loadSessions();
                    }
                  },
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    '${DateFormat.yMd().format(_startDate)} - '
                    '${DateFormat.yMd().format(_endDate)}',
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildSessionsList()),
      ],
    );
  }

  Widget _buildSessionsList() {
    final completedSessions = _sessions
        .where((s) => s.endTime != null)
        .toList();

    if (completedSessions.isEmpty) {
      return const Center(child: Text('No completed sessions'));
    }

    return ListView.builder(
      itemCount: completedSessions.length,
      itemBuilder: (context, index) {
        final session = completedSessions[index];
        return FutureBuilder(
          future: Future.wait([
            _db.getCustomer(session.customerId),
            _db.getMachine(session.machineId),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const ListTile(title: Text('Loading...'));
            }

            final customer = snapshot.data![0] as Customer?;
            final machine = snapshot.data![1] as Machine?;

            return ListTile(
              title: Text(customer?.name ?? 'Unknown Customer'),
              subtitle: Text(
                '${machine?.name ?? 'Unknown Machine'} - '
                '${DateFormat.yMd().add_jm().format(session.startTime)}',
              ),
              trailing: Text(
                '\$${session.finalAmount?.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _showSessionDetails(session),
            );
          },
        );
      },
    );
  }

  Future<void> _showEndSessionDialog(Session session) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Amount: \$${session.currentAmount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 16),
            const Text('Are you sure you want to end this session?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End Session'),
          ),
        ],
      ),
    );

    if (result == true) {
      final updatedSession = Session(
        id: session.id,
        customerId: session.customerId,
        machineId: session.machineId,
        startTime: session.startTime,
        endTime: DateTime.now(),
        paymentStatus: session.paymentStatus,
        paymentType: session.paymentType,
        hourlyRate: session.hourlyRate,
        finalAmount: session.currentAmount,
      );
      await _db.updateSession(updatedSession);
      _loadSessions();
    }
  }

  Future<void> _showSessionDetails(Session session) async {
    final customer = await _db.getCustomer(session.customerId);
    final machine = await _db.getMachine(session.machineId);

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Customer'),
              subtitle: Text(customer?.name ?? 'Unknown'),
            ),
            ListTile(
              title: const Text('Machine'),
              subtitle: Text(machine?.name ?? 'Unknown'),
            ),
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(
                DateFormat.yMd().add_jm().format(session.startTime),
              ),
            ),
            if (session.endTime != null)
              ListTile(
                title: const Text('End Time'),
                subtitle: Text(
                  DateFormat.yMd().add_jm().format(session.endTime!),
                ),
              ),
            ListTile(
              title: const Text('Duration'),
              subtitle: Text(_formatDuration(session.duration)),
            ),
            ListTile(
              title: const Text('Amount'),
              subtitle: Text(
                '\$${session.finalAmount?.toStringAsFixed(2) ?? session.currentAmount.toStringAsFixed(2)}',
              ),
            ),
            ListTile(
              title: const Text('Payment Status'),
              subtitle: Text(session.paymentStatus.toString().split('.').last),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '$hours hours $minutes minutes';
  }
}
