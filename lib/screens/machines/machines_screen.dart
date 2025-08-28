import 'package:flutter/material.dart';
import '../../models/machine.dart';
import '../../services/database_service.dart';

class MachinesScreen extends StatefulWidget {
  const MachinesScreen({super.key});

  @override
  State<MachinesScreen> createState() => _MachinesScreenState();
}

class _MachinesScreenState extends State<MachinesScreen> {
  final DatabaseService _db = DatabaseService.instance;
  List<Machine> _machines = [];

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

  Future<void> _loadMachines() async {
    final machines = await _db.getAllMachines();
    setState(() {
      _machines = machines;
    });
  }

  Color _getStatusColor(MachineStatus status) {
    switch (status) {
      case MachineStatus.available:
        return Colors.green;
      case MachineStatus.inUse:
        return Colors.blue;
      case MachineStatus.maintenance:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.04;
    final cardWidth = (size.width - padding * 3) / 2;
    final cardHeight = size.height * 0.22;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadMachines,
        child: _machines.isEmpty
            ? const Center(child: Text('No machines yet'))
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(padding),
                    child: Wrap(
                      spacing: padding,
                      runSpacing: padding,
                      children: _machines.map((machine) {
                        return SizedBox(
                          width: cardWidth,
                          height: cardHeight,
                          child: _buildMachineCard(machine, cardHeight, size),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMachineDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMachineCard(Machine machine, double cardHeight, Size size) {
    final iconSize = size.width * 0.09;
    final statusFont = size.width * 0.03;
    final padding = cardHeight * 0.13;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showMachineDetails(machine),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: _getStatusColor(machine.status).withOpacity(0.2),
              padding: EdgeInsets.all(padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    machine.type == MachineType.pc
                        ? Icons.computer
                        : Icons.gamepad,
                    size: iconSize,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: padding * 0.5,
                      vertical: padding * 0.3,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(machine.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      machine.status.toString().split('.').last,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: statusFont,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    machine.name,
                    style: TextStyle(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: cardHeight * 0.07),
                  Text(
                    '\$${machine.hourlyRate}/hr',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: size.width * 0.04,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddMachineDialog() async {
    final result = await showDialog<Machine>(
      context: context,
      builder: (context) => const MachineDialog(),
    );
    if (result != null) {
      await _db.createMachine(result);
      _loadMachines();
    }
  }
  // Removed duplicate _showAddMachineDialog

  Future<void> _showMachineDetails(Machine machine) async {
    await showDialog<Machine>(
      context: context,
      builder: (context) => MachineDetailsDialog(machine: machine),
    );
    _loadMachines();
  }
}

class MachineDialog extends StatefulWidget {
  final Machine? machine;

  const MachineDialog({this.machine, super.key});

  @override
  State<MachineDialog> createState() => _MachineDialogState();
}

class _MachineDialogState extends State<MachineDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late MachineType _type;
  late String _specifications;
  late double _hourlyRate;
  late MachineStatus _status;

  @override
  void initState() {
    super.initState();
    _type = widget.machine?.type ?? MachineType.pc;
    _status = widget.machine?.status ?? MachineStatus.available;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.machine == null ? 'Add Machine' : 'Edit Machine'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: widget.machine?.name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MachineType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: MachineType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
              ),
              TextFormField(
                initialValue: widget.machine?.specifications,
                decoration: const InputDecoration(labelText: 'Specifications'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter specifications';
                  }
                  return null;
                },
                onSaved: (value) => _specifications = value!,
              ),
              TextFormField(
                initialValue: widget.machine?.hourlyRate.toString(),
                decoration: const InputDecoration(
                  labelText: 'Hourly Rate',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an hourly rate';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => _hourlyRate = double.parse(value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MachineStatus>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: MachineStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.machine == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final machine = Machine(
        id: widget.machine?.id,
        name: _name,
        type: _type,
        specifications: _specifications,
        status: _status,
        hourlyRate: _hourlyRate,
      );
      Navigator.pop(context, machine);
    }
  }
}

class MachineDetailsDialog extends StatelessWidget {
  final Machine machine;
  final DatabaseService _db = DatabaseService.instance;

  MachineDetailsDialog({required this.machine, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(machine.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(
                machine.type == MachineType.pc ? Icons.computer : Icons.gamepad,
              ),
              title: Text(
                machine.type.toString().split('.').last.toUpperCase(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Specifications'),
              subtitle: Text(machine.specifications),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: Text('\$${machine.hourlyRate}/hour'),
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: Text(machine.status.toString().split('.').last),
              trailing: machine.status == MachineStatus.inUse
                  ? Text(
                      'Current cost: \$${machine.currentSessionCost.toStringAsFixed(2)}',
                    )
                  : null,
            ),
            if (machine.lastMaintenanceDate != null)
              ListTile(
                leading: const Icon(Icons.build),
                title: const Text('Last Maintenance'),
                subtitle: Text(machine.lastMaintenanceDate.toString()),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () async {
            final result = await showDialog<Machine>(
              context: context,
              builder: (context) => MachineDialog(machine: machine),
            );
            if (result != null) {
              await _db.updateMachine(result);
              if (context.mounted) Navigator.pop(context);
            }
          },
          child: const Text('Edit'),
        ),
        if (machine.status == MachineStatus.available)
          TextButton(
            onPressed: () async {
              // TODO: Implement start session functionality
              Navigator.pop(context);
            },
            child: const Text('Start Session'),
          ),
        if (machine.status == MachineStatus.inUse)
          TextButton(
            onPressed: () async {
              // TODO: Implement end session functionality
              Navigator.pop(context);
            },
            child: const Text('End Session'),
          ),
        TextButton(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirm Delete'),
                content: const Text(
                  'Are you sure you want to delete this machine?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await _db.deleteMachine(machine.id);
              if (context.mounted) Navigator.pop(context);
            }
          },
          child: const Text('Delete'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
      ],
    );
  }
}
