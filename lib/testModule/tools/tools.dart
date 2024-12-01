double calculateExpectation(List<double> values, List<double> probabilities) {
  assert(values.length == probabilities.length);

  double expectation = 0.0;

  for (int i = 0; i < values.length; i++) {
    expectation += values[i] * probabilities[i];
  }

  return expectation;
}