import 'booster_result.dart';

/// The laptop booster's settings (docs/LAPTOP_PLAN.md, L4), kept in the
/// private database. Off means not even the local check runs.
class BoosterPrefs {
  const BoosterPrefs({
    this.on = true,
    this.address = defaultAddress,
    this.ownNetwork = false,
    this.model,
    this.jobs = const {...BoosterKind.values},
  });

  /// LM Studio's default (product spec §5).
  static const defaultAddress = 'http://localhost:1234/v1';

  final bool on;
  final String address;

  /// Also accept an AI app on another of the user's own computers.
  final bool ownNetwork;

  /// The model to use; null picks the first one the app offers.
  final String? model;

  /// Which of the four jobs run.
  final Set<BoosterKind> jobs;

  BoosterPrefs copyWith({
    bool? on,
    String? address,
    bool? ownNetwork,
    String? Function()? model,
    Set<BoosterKind>? jobs,
  }) => BoosterPrefs(
    on: on ?? this.on,
    address: address ?? this.address,
    ownNetwork: ownNetwork ?? this.ownNetwork,
    model: model == null ? this.model : model(),
    jobs: jobs ?? this.jobs,
  );

  Map<String, Object?> toJson() => {
    'on': on,
    'address': address,
    'ownNetwork': ownNetwork,
    'model': model,
    'jobs': [for (final j in jobs) j.name],
  };

  /// Unknown or damaged values fall back to the defaults.
  static BoosterPrefs fromJson(Object? json) {
    if (json is! Map) return const BoosterPrefs();
    final jobs = json['jobs'];
    final address = json['address'];
    final model = json['model'];
    return BoosterPrefs(
      on: json['on'] != false,
      address: address is String && address.isNotEmpty
          ? address
          : defaultAddress,
      ownNetwork: json['ownNetwork'] == true,
      model: model is String && model.isNotEmpty ? model : null,
      jobs: jobs is List
          ? {for (final j in jobs) ?BoosterKind.values.asNameMap()[j]}
          : const {...BoosterKind.values},
    );
  }
}
