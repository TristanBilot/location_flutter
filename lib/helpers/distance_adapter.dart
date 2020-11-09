class DistanceAdapter {
  String adapt(int distance) {
    if (distance < 1000) return '${distance}m';
    return '${(distance / 1000).round()}km';
  }
}
