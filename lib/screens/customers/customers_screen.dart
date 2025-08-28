import 'package:flutter/material.dart';
import '../../models/customer.dart';
import '../../services/database_service.dart';
import '../../models/session.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final DatabaseService _db = DatabaseService.instance;
  List<Customer> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final customers = await _db.getAllCustomers();
    setState(() {
      _customers = customers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).size.width * 0.04;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadCustomers,
        child: _customers.isEmpty
            ? const Center(child: Text('No customers yet'))
            : ListView.builder(
                padding: EdgeInsets.all(padding),
                itemCount: _customers.length,
                itemBuilder: (context, index) {
                  final customer = _customers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(customer.name[0].toUpperCase()),
                    ),
                    title: Text(customer.name),
                    subtitle: Text(customer.email),
                    trailing: Text(
                      customer.membershipType != MembershipType.none
                          ? customer.membershipType.toString().split('.').last
                          : 'No Membership',
                    ),
                    onTap: () => _showCustomerDetails(customer),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddCustomerDialog() async {
    final result = await showDialog<Customer>(
      context: context,
      builder: (context) => const CustomerDialog(),
    );

    if (result != null) {
      await _db.createCustomer(result);
      _loadCustomers();
    }
  }

  Future<void> _showCustomerDetails(Customer customer) async {
    await showDialog<Customer>(
      context: context,
      builder: (context) => CustomerDetailsDialog(customer: customer),
    );
    _loadCustomers();
  }
}

class CustomerDialog extends StatefulWidget {
  final Customer? customer;

  const CustomerDialog({this.customer, super.key});

  @override
  State<CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<CustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _phone;
  MembershipType _membershipType = MembershipType.none;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _name = widget.customer!.name;
      _email = widget.customer!.email;
      _phone = widget.customer!.phone;
      _membershipType = widget.customer!.membershipType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.customer == null ? 'Add Customer' : 'Edit Customer'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: widget.customer?.name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: widget.customer?.email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                initialValue: widget.customer?.phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
                onSaved: (value) => _phone = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MembershipType>(
                value: _membershipType,
                decoration: const InputDecoration(labelText: 'Membership Type'),
                items: MembershipType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _membershipType = value!;
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
          child: Text(widget.customer == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final customer = Customer(
        id: widget.customer?.id,
        name: _name,
        email: _email,
        phone: _phone,
        membershipType: _membershipType,
      );
      Navigator.pop(context, customer);
    }
  }
}

class CustomerDetailsDialog extends StatefulWidget {
  final Customer customer;

  const CustomerDetailsDialog({required this.customer, super.key});

  @override
  State<CustomerDetailsDialog> createState() => _CustomerDetailsDialogState();
}

class _CustomerDetailsDialogState extends State<CustomerDetailsDialog> {
  final DatabaseService _db = DatabaseService.instance;
  List<Session> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await _db.getCustomerSessions(widget.customer.id);
    setState(() {
      _sessions = sessions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.customer.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(widget.customer.email),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(widget.customer.phone),
            ),
            ListTile(
              leading: const Icon(Icons.card_membership),
              title: Text(
                widget.customer.membershipType.toString().split('.').last,
              ),
            ),
            const Divider(),
            const Text('Recent Sessions:'),
            ..._sessions.map(
              (session) => ListTile(
                title: Text(
                  '${session.startTime.toString()} - '
                  '${session.endTime != null ? session.endTime.toString() : 'Ongoing'}',
                ),
                trailing: Text(
                  '\$${session.finalAmount != null ? session.finalAmount : session.currentAmount}',
                ),
              ),
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
            final result = await showDialog<Customer>(
              context: context,
              builder: (context) => CustomerDialog(customer: widget.customer),
            );
            if (result != null) {
              await _db.updateCustomer(result);
              if (mounted) Navigator.pop(context);
            }
          },
          child: const Text('Edit'),
        ),
        TextButton(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirm Delete'),
                content: const Text(
                  'Are you sure you want to delete this customer?',
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
              await _db.deleteCustomer(widget.customer.id);
              if (mounted) Navigator.pop(context);
            }
          },
          child: const Text('Delete'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
      ],
    );
  }
}
