import 'package:fasomo/core/theme/sky_art.dart';

/// Which static sky to show at [localTime]: day from 06:00 to 17:59, night
/// otherwise.
///
/// A fixed window stands in until the sky header computes real sunrise and
/// sunset for the user's location (see docs/plans/home-sky-header.md).
SkyArt skyArtAt(DateTime localTime) =>
    localTime.hour >= 6 && localTime.hour < 18 ? SkyArt.day : SkyArt.night;
