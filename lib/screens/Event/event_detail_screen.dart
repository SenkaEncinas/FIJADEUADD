import 'package:flutter/material.dart';
import 'package:uadd_app/models/Event/event_dto.dart';
import '../../models/event/event_detail_dto.dart';
import '../../services/event_service.dart';

class EventDetailScreen extends StatefulWidget {
  final int eventId;
  final EventDto event;

  const EventDetailScreen({
    super.key, 
    required this.eventId, 
    required this.event,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final _eventService = EventService();
  late Future<EventDetailDto> _futureEvent;
  bool _isLoading = false;

  // Paleta de colores verde
  final Color _primaryColor = const Color(0xFF2E7D32);
  final Color _primaryLight = const Color(0xFF60AD5E);
  final Color _primaryDark = const Color(0xFF005005);
  final Color _accentColor = const Color(0xFF8BC34A);
  final Color _backgroundColor = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  void _loadEvent() {
    setState(() {
      _futureEvent = _eventService.getEventById(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: _primaryColor,
          secondary: _accentColor,
        ),
      ),
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: const Text('Detalles del Evento',
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
          elevation: 4,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
          ],
        ),
        body: FutureBuilder<EventDetailDto>(
          future: _futureEvent,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: _primaryColor),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: _primaryDark),
                    const SizedBox(height: 16),
                    Text('Error al cargar el evento',
                        style: TextStyle(
                            fontSize: 18,
                            color: _primaryDark,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Reintentar',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              return Center(
                child: Text('Evento no encontrado',
                    style: TextStyle(
                        fontSize: 18,
                        color: _primaryDark,
                        fontWeight: FontWeight.w500)),
              );
            }

            final event = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Image with shadow and border radius
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        event.imageUrl,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 220,
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(Icons.image_not_supported,
                                size: 48, color: Colors.grey[400]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Event Title with decorative underline
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _primaryDark,
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 4,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: _accentColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Event Details Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            Icons.calendar_today_outlined,
                            'Fecha: ${_formatDate(event.date)}',
                            _primaryColor,
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            Icons.location_on_outlined,
                            'Lugar: ${event.location}',
                            _primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description Section
                  if (event.description != null && event.description.isNotEmpty)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.description_outlined,
                                    color: _primaryLight),
                                const SizedBox(width: 8),
                                Text(
                                  'Descripción',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              event.description!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Additional Info Space
                  const SizedBox(height: 30),
                ],
              
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Action to register for the event
          },
          backgroundColor: _primaryColor,
          icon: const Icon(Icons.event_available, color: Colors.white),
          label: const Text('Registrarse', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$day/$month/$year $hour:$minute';
  }
}