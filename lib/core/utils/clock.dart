/// Interface pour fournir l'heure courante (permet de simuler les années dans les tests).
abstract class Clock {
  DateTime now();
}

/// Implémentation basée sur l'horloge système.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
