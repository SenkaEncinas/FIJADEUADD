import 'package:flutter/material.dart';
import 'package:uadd_app/models/Event/event_dto.dart';
import 'package:uadd_app/screens/Event/event_detail_screen.dart';
import 'package:uadd_app/screens/User/user_home_screen.dart';
import '../../services/event_service.dart';
import '../login_screen.dart';
import 'user_match_screen.dart'; // Nueva importación

class UserEventScreen extends StatefulWidget {
  const UserEventScreen({super.key});

  @override
  State<UserEventScreen> createState() => _UserEventScreenState();
}

class _UserEventScreenState extends State<UserEventScreen> {
  final _eventService = EventService();
  late Future<List<EventDto>> _futureEvents;
  List<EventDto> _filteredEvents = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedLocation = 'Todas';
  final List<String> _locations = [
    'Todas',
    'Coliseo',
    'Cancha',
    'Aula Magna',
    'Centro De Convenciones',
    'Pascanita',
    'Jatata',
    'Cafeteria',
    'Sala de estudio',
    'Sala de mate',
  ];

  @override
  void initState() {
    super.initState();
    _futureEvents = _loadEvents();
    _searchController.addListener(_filterEvents);
  }

  Future<List<EventDto>> _loadEvents() async {
    try {
      final events = await _eventService.getAllEvents();
      _filteredEvents = events;
      return events;
    } catch (e) {
      debugPrint('Error loading events: $e');
      _filteredEvents = [];
      return [];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshEvents() async {
    setState(() {
      _futureEvents = _loadEvents();
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _filterEvents() {
    _futureEvents.then((events) {
      if (events.isEmpty) return;
      
      setState(() {
        _filteredEvents = events.where((event) {
          final matchesSearch = _searchController.text.isEmpty || 
              (event.title?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);
          final matchesLocation = _selectedLocation == 'Todas' || 
              (event.location == _selectedLocation);
          return matchesSearch && matchesLocation;
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      primaryColor: const Color(0xFF2E7D32),
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: const Color(0xFF2E7D32),
            secondary: const Color(0xFF81C784),
          ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        drawer: _buildDrawer(theme),
        appBar: _buildAppBar(theme),
        body: _buildBody(theme),
      ),
    );
  }

  Widget _buildDrawer(ThemeData theme) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.primaryColor,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Menú de Navegación',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Selecciona una opción',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'FUNCIONALIDADES',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
                leading: Icon(Icons.event, color: theme.primaryColor),
                title: const Text('Eventos'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserEventScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.sports, color: theme.primaryColor),
                title: const Text('Matchs'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserMatchScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.paid, color: theme.primaryColor),
                title: const Text('Ventas'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserHomeScreen()),
                  );
                },
              ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: theme.primaryColor),
            title: const Text('Cerrar Sesión'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: const Text('Eventos',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20)),
      centerTitle: true,
      backgroundColor: theme.primaryColor,
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(15),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _refreshEvents,
          tooltip: 'Actualizar',
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: _logout,
          tooltip: 'Cerrar sesión',
        ),
      ],
    );
  }

  Widget _buildBody(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _refreshEvents,
      color: theme.primaryColor,
      child: FutureBuilder<List<EventDto>>(
        future: _futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorWidget(theme);
          }

          return Column(
            children: [
              _buildSearchFilters(theme),
              _buildEventsList(theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.primaryColor),
          const SizedBox(height: 16),
          Text('Error al cargar eventos',
              style: TextStyle(fontSize: 16, color: theme.primaryColor)),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _refreshEvents,
            child: const Text('Reintentar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilters(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 30,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                hintText: 'Buscar eventos...',
                prefixIcon: Icon(Icons.search, size: 20, color: theme.primaryColor),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.primaryColor, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.primaryColor, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 30,
            child: DropdownButtonFormField<String>(
              isDense: true,
              value: _selectedLocation,
              dropdownColor: Colors.white,
              icon: Icon(Icons.arrow_drop_down, size: 20, color: theme.primaryColor),
              items: _locations.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, 
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.primaryColor
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedLocation = newValue!;
                  _filterEvents();
                });
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                labelText: 'Ubicación',
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: theme.primaryColor
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.primaryColor, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.primaryColor, width: 1),
                ),
              ),
            ),
          ),
          ],
        ),
      );
    }

    Widget _buildEventsList(ThemeData theme) {
      return Expanded(
        child: _filteredEvents.isEmpty
            ? _buildNoResultsWidget(theme)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = _filteredEvents[index];
                  return _buildEventCard(theme, event);
                },
              ),
      );
    }

    Widget _buildNoResultsWidget(ThemeData theme) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: theme.primaryColor),
            const SizedBox(height: 16),
            Text('No se encontraron eventos',
                style: TextStyle(fontSize: 16, color: theme.primaryColor)),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedLocation = 'Todas';
                  _filterEvents();
                });
              },
              child: const Text('Limpiar filtros',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    Widget _buildEventCard(ThemeData theme, EventDto event) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: theme.primaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailScreen(event: event, eventId: event.id,),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15)),
                child: Stack(
                  children: [
                    _buildEventImage(theme, event),
                    _buildEventDateBadge(event),
                  ],
                ),
              ),
              _buildEventDetails(theme, event),
            ],
          ),
        ),
      );
    }

    Widget _buildEventImage(ThemeData theme, EventDto event) {
      return Image.network(
        event.imageUrl ?? '',
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          height: 200,
          color: Colors.grey[200],
          child: Center(
            child: Icon(Icons.broken_image,
                size: 50, color: theme.primaryColor),
          ),
        ),
      );
    }

    Widget _buildEventDateBadge(EventDto event) {
      return Positioned(
        bottom: 10,
        left: 10,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            event.date != null
                ? '${event.date!.day}/${event.date!.month}/${event.date!.year}'
                : 'Fecha no disponible',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    Widget _buildEventDetails(ThemeData theme, EventDto event) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title ?? 'Sin título',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on,
                    size: 16, color: theme.primaryColor),
                const SizedBox(width: 4),
                Text(
                  event.location ?? 'Ubicación no disponible',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: theme.primaryColor),
                const SizedBox(width: 4),
                Text(
                  event.date != null
                      ? '${event.date!.day}/${event.date!.month}/${event.date!.year}'
                      : 'Fecha no disponible',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.access_time,
                    size: 16, color: theme.primaryColor),
                const SizedBox(width: 4),
                Text(
                  event.date != null
                      ? '${event.date!.hour}:${event.date!.minute.toString().padLeft(2, '0')}'
                      : 'Hora no disponible',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }