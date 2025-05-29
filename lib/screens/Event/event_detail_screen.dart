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

  // Modern color palette with green tones
  final Color _primaryColor = const Color(0xFF00C853); // Vibrant green
  final Color _primaryLight = const Color(0xFF5EFC82); // Light green
  final Color _primaryDark = const Color(0xFF009624); // Dark green
  final Color _accentColor = const Color(0xFF69F0AE); // Accent green
  final Color _backgroundColor = const Color(0xFFFAFAFA); // Very light grey
  final Color _textColor = const Color(0xFF424242); // Dark grey for text
  final Color _secondaryTextColor = const Color(0xFF757575); // Medium grey

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
          surface: Colors.white,
          background: _backgroundColor,
        ),
      ),
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: Text('Detalles del Evento',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              )),
          centerTitle: true,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor, _primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.8)),
                ),
              ),
              )
          ],
        ),
        body: FutureBuilder<EventDetailDto>(
          future: _futureEvent,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: _primaryColor,
                        backgroundColor: _primaryColor.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Cargando evento...',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: _primaryDark),
                      const SizedBox(height: 20),
                      Text(
                        'Error al cargar el evento',
                        style: TextStyle(
                          fontSize: 20,
                          color: _primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Por favor verifica tu conexión e intenta nuevamente',
                        style: TextStyle(
                          fontSize: 16,
                          color: _secondaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _loadEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          shadowColor: _primaryColor.withOpacity(0.3),
                        ),
                        child: const Text(
                          'Reintentar',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 60, color: _primaryDark),
                    const SizedBox(height: 20),
                    Text(
                      'Evento no encontrado',
                      style: TextStyle(
                        fontSize: 20,
                        color: _primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }

            final event = snapshot.data!;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image with gradient overlay
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Container(
                        height: 260,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          child: Image.network(
                            event.imageUrl,
                            width: double.infinity,
                            height: 260,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 260,
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(Icons.image_not_supported,
                                    size: 60, color: Colors.grey[400]),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 260,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _formatDate(event.date),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              event.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 6,
                                    color: Colors.black45,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Event Details Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location Card
                        _buildInfoCard(
                          icon: Icons.location_on_outlined,
                          title: 'Ubicación',
                          content: event.location,
                          iconColor: _primaryColor,
                        ),
                        const SizedBox(height: 16),

                        // Description Section
                        if (event.description != null && event.description.isNotEmpty)
                          _buildInfoCard(
                            icon: Icons.description_outlined,
                            title: 'Descripción',
                            content: event.description!,
                            iconColor: _primaryColor,
                          ),
                      ],
                    ),
                  ),

                  // Additional Info Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Descripcion del Evento',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _primaryDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailItem(
                            Icons.description,
                            event.description,
                            _primaryColor,
                        ),  
                      ],
                    ),
                  ),
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
          elevation: 4,
          icon: const Icon(Icons.event_available, color: Colors.white, size: 24),
          label: const Text(
            'Registrarse',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: _secondaryTextColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: _textColor,
              ),
            ),
          ),
        ],
      ),
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