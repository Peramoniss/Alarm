class Repository {
  final List<String> weekDays = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo'
  ];

  /////////////////////////////////////////////////////////////////////////////////////////

  String getWeekDay(String inputDay) {
    final Map<String, String> dayMap = {
      'segunda': 'Segunda-feira',
      'terca': 'Terça-feira',
      'quarta': 'Quarta-feira',
      'quinta': 'Quinta-feira',
      'sexta': 'Sexta-feira',
      'sabado': 'Sábado',
      'domingo': 'Domingo',
    };

    return dayMap[inputDay.toLowerCase()] ?? inputDay;
  }

}
