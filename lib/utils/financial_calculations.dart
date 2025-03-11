import 'dart:math' as math;

class FinancialCalculations {
  // Interés Simple
  static double simpleInterestFutureValue(
    double principal,
    double rate,
    double time,
  ) {
    return principal * (1 + rate * time);
  }

  static double simpleInterestRate(
    double principal,
    double futureValue,
    double time,
  ) {
    return (futureValue / principal - 1) / time;
  }

  static double simpleInterestTime(
    double principal,
    double futureValue,
    double rate,
  ) {
    return (futureValue / principal - 1) / rate;
  }

  // Interés Compuesto
  static double compoundInterestFutureValue(
    double principal,
    double rate,
    double time,
    int compoundingPerPeriod,
  ) {
    return principal *
        math.pow(
          (1 + rate / compoundingPerPeriod),
          compoundingPerPeriod * time,
        );
  }

  static double compoundInterestRate(
    double principal,
    double futureValue,
    double time,
    int compoundingPerPeriod,
  ) {
    return compoundingPerPeriod *
        (math.pow(futureValue / principal, 1 / (compoundingPerPeriod * time)) -
            1);
  }

  static double compoundInterestTime(
    double principal,
    double futureValue,
    double rate,
    int compoundingPerPeriod,
  ) {
    return math.log(futureValue / principal) /
        (compoundingPerPeriod * math.log(1 + rate / compoundingPerPeriod));
  }

  // Gradiente Aritmético
  static double arithmeticGradientPresentValue(
    double firstPayment,
    double gradient,
    double rate,
    int periods,
  ) {
    double annuityFactor = (1 - math.pow(1 + rate, -periods)) / rate;
    double gradientFactor =
        (periods / rate - (1 - math.pow(1 + rate, -periods)) / (rate * rate)) /
        (1 + rate);
    return firstPayment * annuityFactor + gradient * gradientFactor;
  }

  static double arithmeticGradientFutureValue(
    double firstPayment,
    double gradient,
    double rate,
    int periods,
  ) {
    double annuityFactor = (math.pow(1 + rate, periods) - 1) / rate;
    double gradientFactor = (periods - annuityFactor) / rate;
    return firstPayment * annuityFactor + gradient * gradientFactor;
  }

  // Gradiente Geométrico
  static double geometricGradientPresentValue(
    double firstPayment,
    double growthRate,
    double interestRate,
    int periods,
  ) {
    if (growthRate == interestRate) {
      return firstPayment * periods / (1 + interestRate);
    } else {
      return firstPayment *
          (1 - math.pow((1 + growthRate) / (1 + interestRate), periods)) /
          (interestRate - growthRate);
    }
  }

  // Amortización
  static List<Map<String, dynamic>> germanAmortization(
    double principal,
    double rate,
    int periods,
  ) {
    List<Map<String, dynamic>> schedule = [];
    double payment = principal / periods;
    double remainingPrincipal = principal;

    for (int i = 1; i <= periods; i++) {
      double interest = remainingPrincipal * rate;
      double totalPayment = payment + interest;
      remainingPrincipal -= payment;

      schedule.add({
        'period': i,
        'payment': totalPayment,
        'principal': payment,
        'interest': interest,
        'balance': remainingPrincipal,
      });
    }

    return schedule;
  }

  static List<Map<String, dynamic>> frenchAmortization(
    double principal,
    double rate,
    int periods,
  ) {
    List<Map<String, dynamic>> schedule = [];
    double payment =
        principal *
        rate *
        math.pow(1 + rate, periods) /
        (math.pow(1 + rate, periods) - 1);
    double remainingPrincipal = principal;

    for (int i = 1; i <= periods; i++) {
      double interest = remainingPrincipal * rate;
      double principalPart = payment - interest;
      remainingPrincipal -= principalPart;

      schedule.add({
        'period': i,
        'payment': payment,
        'principal': principalPart,
        'interest': interest,
        'balance': remainingPrincipal,
      });
    }

    return schedule;
  }

  static List<Map<String, dynamic>> americanAmortization(
    double principal,
    double rate,
    int periods,
  ) {
    List<Map<String, dynamic>> schedule = [];
    double interest = principal * rate;
    double remainingPrincipal = principal;

    for (int i = 1; i <= periods; i++) {
      double principalPart = i == periods ? principal : 0;
      double payment = interest + principalPart;
      remainingPrincipal = i == periods ? 0 : principal;

      schedule.add({
        'period': i,
        'payment': payment,
        'principal': principalPart,
        'interest': interest,
        'balance': remainingPrincipal,
      });
    }

    return schedule;
  }

  // TIR (Tasa Interna de Retorno)
  static double calculateIRR(
    List<double> cashFlows, {
    double guess = 0.1,
    double precision = 0.0000001,
    int maxIterations = 100,
  }) {
    double rate = guess;
    int iteration = 0;
    double npv = 0;
    double derivative = 0;

    do {
      npv = 0;
      derivative = 0;

      for (int i = 0; i < cashFlows.length; i++) {
        npv += cashFlows[i] / math.pow(1 + rate, i);
        if (i > 0) {
          derivative -= i * cashFlows[i] / math.pow(1 + rate, i + 1);
        }
      }

      double newRate = rate - npv / derivative;
      if ((newRate - rate).abs() < precision) {
        return newRate;
      }

      rate = newRate;
      iteration++;
    } while (iteration < maxIterations);

    throw Exception('IRR calculation did not converge');
  }

  // Agregar este método a la clase FinancialCalculations
  static String formatTimePeriod(int years, int months, int days) {
    List<String> parts = [];
    if (years > 0) {
      parts.add('$years año${years == 1 ? '' : 's'}');
    }
    if (months > 0) {
      parts.add('$months mes${months == 1 ? '' : 'es'}');
    }
    if (days > 0) {
      parts.add('$days día${days == 1 ? '' : 's'}');
    }
    return parts.join(', ');
  }

  // Funciones auxiliares
  static double pow(double x, double y) {
    return x.pow(y);
  }

  static double log(double x) {
    return ln(x);
  }
}

// Extensiones para operaciones matemáticas
extension MathExtensions on double {
  double pow(double exponent) {
    return math.pow(this, exponent).toDouble();
  }
}

double ln(double x) {
  return math.log(x);
}
