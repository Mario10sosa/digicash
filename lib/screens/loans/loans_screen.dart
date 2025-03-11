import 'package:flutter/material.dart';
import 'package:digicash/widgets/custom_button.dart';
import 'package:digicash/screens/calculators/amortization_screen.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({Key? key}) : super(key: key);

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  // Lista de préstamos de ejemplo
  final List<Map<String, dynamic>> _loans = [
    {
      'id': '1',
      'name': 'Préstamo Personal',
      'amount': 5000000,
      'term': 12,
      'rate': 12.5,
      'payment': 445000,
      'startDate': '2023-10-15',
      'progress': 0.7,
      'type': 'Personal',
    },
    {
      'id': '2',
      'name': 'Préstamo Educativo',
      'amount': 2500000,
      'term': 24,
      'rate': 8.0,
      'payment': 113000,
      'startDate': '2023-08-01',
      'progress': 0.3,
      'type': 'Educativo',
    },
    {
      'id': '3',
      'name': 'Crédito Hipotecario',
      'amount': 120000000,
      'term': 240,
      'rate': 9.5,
      'payment': 1100000,
      'startDate': '2022-05-10',
      'progress': 0.05,
      'type': 'Hipotecario',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Préstamos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
            tooltip: 'Filtrar préstamos',
          ),
        ],
      ),
      body: SafeArea(
        child: _loans.isEmpty ? _buildEmptyState() : _buildLoansList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewLoanOptions();
        },
        child: const Icon(Icons.add),
        tooltip: 'Nuevo préstamo',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes préstamos activos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea un nuevo préstamo para comenzar',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Nuevo Préstamo',
            icon: Icons.add,
            onPressed: () {
              _showNewLoanOptions();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoansList() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Préstamos Activos',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Gestiona tus préstamos y realiza pagos',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _loans.length,
              itemBuilder: (context, index) {
                final loan = _loans[index];
                return _buildLoanCard(loan);
              },
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Herramientas de Préstamos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildToolCard(
                    'Calculadora de Amortización',
                    Icons.calculate_outlined,
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AmortizationScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildToolCard(
                    'Comparador de Préstamos',
                    Icons.compare_arrows,
                    Colors.green,
                    () {
                      _showComingSoonDialog('Comparador de Préstamos');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildToolCard(
                    'Capacidad de Endeudamiento',
                    Icons.account_balance_wallet_outlined,
                    Colors.orange,
                    () {
                      _showComingSoonDialog(
                        'Calculadora de Capacidad de Endeudamiento',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildToolCard(
                    'Historial de Pagos',
                    Icons.history,
                    Colors.purple,
                    () {
                      _showComingSoonDialog('Historial de Pagos');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanCard(Map<String, dynamic> loan) {
    final Color cardColor = _getLoanTypeColor(loan['type']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          _showLoanDetails(loan);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      loan['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      loan['type'],
                      style: TextStyle(
                        color: cardColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monto del Préstamo',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_formatNumber(loan['amount'])}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Cuota Mensual',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_formatNumber(loan['payment'])}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Plazo: ${loan['term']} meses',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    'Tasa: ${loan['rate']}%',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(loan['progress'] * 100).toInt()}% pagado',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    'Inicio: ${loan['startDate']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: loan['progress'],
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(cardColor),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _showPaymentDialog(loan);
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text('Pagar'),
                    style: TextButton.styleFrom(foregroundColor: cardColor),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      _showLoanDetails(loan);
                    },
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Ver Detalles'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoanDetails(Map<String, dynamic> loan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            loan['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailItem('Tipo de Préstamo', loan['type']),
                    _buildDetailItem(
                      'Monto del Préstamo',
                      '\$${_formatNumber(loan['amount'])}',
                    ),
                    _buildDetailItem('Tasa de Interés', '${loan['rate']}%'),
                    _buildDetailItem('Plazo', '${loan['term']} meses'),
                    _buildDetailItem(
                      'Cuota Mensual',
                      '\$${_formatNumber(loan['payment'])}',
                    ),
                    _buildDetailItem('Fecha de Inicio', loan['startDate']),
                    _buildDetailItem(
                      'Progreso',
                      '${(loan['progress'] * 100).toInt()}% pagado',
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Próximos Pagos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Próximos pagos (ejemplo)
                    _buildPaymentItem(
                      '15/11/2023',
                      loan['payment'],
                      'Pendiente',
                    ),
                    _buildPaymentItem(
                      '15/12/2023',
                      loan['payment'],
                      'Pendiente',
                    ),
                    _buildPaymentItem(
                      '15/01/2024',
                      loan['payment'],
                      'Pendiente',
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Historial de Pagos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Historial de pagos (ejemplo)
                    _buildPaymentItem('15/10/2023', loan['payment'], 'Pagado'),
                    _buildPaymentItem('15/09/2023', loan['payment'], 'Pagado'),
                    _buildPaymentItem('15/08/2023', loan['payment'], 'Pagado'),

                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Realizar Pago',
                      icon: Icons.payment,
                      onPressed: () {
                        Navigator.pop(context);
                        _showPaymentDialog(loan);
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Ver Tabla de Amortización',
                      icon: Icons.table_chart_outlined,
                      isOutlined: true,
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AmortizationScreen(),
                          ),
                        );
                      },
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

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(String date, double amount, String status) {
    final Color statusColor = status == 'Pagado' ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            '\$${_formatNumber(amount)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(Map<String, dynamic> loan) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Realizar Pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Préstamo: ${loan['name']}'),
              const SizedBox(height: 8),
              Text('Cuota Mensual: \$${_formatNumber(loan['payment'])}'),
              const SizedBox(height: 16),
              const Text(
                'Selecciona un método de pago:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildPaymentMethodOption(
                'Tarjeta de Crédito',
                Icons.credit_card,
              ),
              _buildPaymentMethodOption(
                'Cuenta Bancaria',
                Icons.account_balance,
              ),
              _buildPaymentMethodOption('PSE', Icons.public),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showPaymentSuccessDialog();
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentMethodOption(String method, IconData icon) {
    return InkWell(
      onTap: () {
        // Seleccionar método de pago
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [Icon(icon), const SizedBox(width: 12), Text(method)],
        ),
      ),
    );
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pago Exitoso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                '¡Tu pago ha sido procesado exitosamente!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Número de confirmación: ${DateTime.now().millisecondsSinceEpoch}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrar Préstamos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('Todos los Préstamos', true),
              _buildFilterOption('Préstamos Personales', false),
              _buildFilterOption('Préstamos Educativos', false),
              _buildFilterOption('Préstamos Hipotecarios', false),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Aplicar filtros
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(String option, bool isSelected) {
    return CheckboxListTile(
      title: Text(option),
      value: isSelected,
      onChanged: (value) {
        // Cambiar selección
      },
    );
  }

  void _showNewLoanOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nuevo Préstamo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecciona el tipo de préstamo que deseas solicitar',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildLoanTypeOption(
                'Préstamo Personal',
                'Para gastos personales, viajes, etc.',
                Icons.person_outline,
                Colors.blue,
              ),
              _buildLoanTypeOption(
                'Préstamo Educativo',
                'Para estudios, cursos, etc.',
                Icons.school_outlined,
                Colors.green,
              ),
              _buildLoanTypeOption(
                'Préstamo Hipotecario',
                'Para compra de vivienda',
                Icons.home_outlined,
                Colors.orange,
              ),
              _buildLoanTypeOption(
                'Préstamo de Vehículo',
                'Para compra de automóvil',
                Icons.directions_car_outlined,
                Colors.purple,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoanTypeOption(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _showComingSoonDialog('Solicitud de $title');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Próximamente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.engineering_outlined,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                '$feature estará disponible próximamente.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Estamos trabajando para ofrecerte esta funcionalidad lo antes posible.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  Color _getLoanTypeColor(String type) {
    switch (type) {
      case 'Personal':
        return Colors.blue;
      case 'Educativo':
        return Colors.green;
      case 'Hipotecario':
        return Colors.orange;
      case 'Vehículo':
        return Colors.purple;
      default:
        return Theme.of(context).primaryColor;
    }
  }

  String _formatNumber(double number) {
    return number
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
