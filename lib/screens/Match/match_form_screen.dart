import 'package:flutter/material.dart';
import 'package:uadd_app/models/Match/match_dto.dart';
import 'package:uadd_app/services/match_service.dart';

class MatchFormScreen extends StatefulWidget {
  final MatchDto? editMatch;
  final MatchService matchService;
  
  const MatchFormScreen({super.key, this.editMatch, required this.matchService});

  @override
  State<MatchFormScreen> createState() => _MatchFormScreenState();
}

class _MatchFormScreenState extends State<MatchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _teamAController;
  late TextEditingController _teamBController;
  late TextEditingController _locationController;
  late TextEditingController _imageUrlController;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedSportType = 'Fútbol';

  // Lista de tipos de deporte disponibles
  static const List<String> sportTypes = [
    'Fútbol',
    'Baloncesto',
    'Tenis',
    'Voleibol',
    'Béisbol'
  ];

  @override
  void initState() {
    super.initState();
    final match = widget.editMatch;
    _titleController = TextEditingController(text: match?.title ?? '');
    _teamAController = TextEditingController(text: match?.teamA ?? '');
    _teamBController = TextEditingController(text: match?.teamB ?? '');
    _locationController = TextEditingController(text: match?.location ?? '');
    _imageUrlController = TextEditingController(text: match?.imageUrl ?? '');

    // Inicializar el tipo de deporte
    if (match != null && match.sportType.isNotEmpty) {
      _selectedSportType = match.sportType;
    }

    if (match != null) {
      _selectedDate = match.matchDate;
      _selectedTime = TimeOfDay.fromDateTime(match.matchDate);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _teamAController.dispose();
    _teamBController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    
    if (pickedDate != null) {
      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final match = MatchDto(
        id: widget.editMatch?.id ?? 0,
        title: _titleController.text,
        teamA: _teamAController.text,
        teamB: _teamBController.text,
        matchDate: _selectedDate,
        location: _locationController.text,
        sportType: _selectedSportType,
        imageUrl: _imageUrlController.text,
      );

      Navigator.pop(context, 'Partido ${widget.editMatch == null ? 'creado' : 'actualizado'} correctamente');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.editMatch != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Partido' : 'Crear Partido'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
            tooltip: 'Guardar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo: Título del partido
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título del partido',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Equipos
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _teamAController,
                      decoration: const InputDecoration(
                        labelText: 'Equipo Local',
                        prefixIcon: Icon(Icons.people),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa el equipo local';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _teamBController,
                      decoration: const InputDecoration(
                        labelText: 'Equipo Visitante',
                        prefixIcon: Icon(Icons.people_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa el equipo visitante';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Fecha y Hora
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hora',
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Campo: Ubicación
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una ubicación';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: Tipo de Deporte
              DropdownButtonFormField<String>(
                value: _selectedSportType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Deporte',
                  prefixIcon: Icon(Icons.sports),
                  border: OutlineInputBorder(),
                ),
                items: sportTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSportType = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecciona un deporte';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo: URL de la imagen
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de la imagen (opcional)',
                  prefixIcon: Icon(Icons.image),
                  border: OutlineInputBorder(),
                  hintText: 'https://ejemplo.com/imagen.jpg',
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final uri = Uri.tryParse(value);
                    if (uri == null || !uri.hasAbsolutePath) {
                      return 'Ingresa una URL válida';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botón de guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(
                    isEditing ? 'Actualizar Partido' : 'Crear Partido',
                    style: const TextStyle(fontSize: 16),
                  ),
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}