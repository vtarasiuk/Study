const int LED_LEAST = 8;
const int LED_LAST = 11;

void power_LEDs(int decimal);
void count_up(const int limit);
bool check_bit(int number, int bit_index);

void setup()
{
  for (int i = LED_LEAST; i <= LED_LAST; i++) {
  	pinMode(i, OUTPUT);
  }
}

void loop()
{
  // 0000 -> 1111
  const int limit = 16;
  for (int i = 0; i < limit; i++) {
  	count_up(limit);
    delay(500);
  }
}

void count_up(const int limit) {
  static int number;
  power_LEDs(number);
  number++;
  if (number >= limit) {
    number = 0;
  }
}

bool check_bit(int number, int bit_index) {
  int value = 1;
  for (int i = 0; i < bit_index; i++) {
  	value *= 2;
  }

  return number & value;
}

void power_LEDs(int decimal) {
  for (int pin = LED_LEAST, bit = 0; pin <= LED_LAST; pin++) {
    if (check_bit(decimal, bit)) {
      digitalWrite(pin, HIGH);
    } else {
      digitalWrite(pin, LOW);
    }
    bit++;
  }
}