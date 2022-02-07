import time
import spidev
bus = 0
device = 0
spi = spidev.SpiDev()
spi.open(bus, device)
spi.max_speed_hz = 5000

help(spi)
print(dir(spi))
print(spi.max_speed_hz)

while True:
	spi.writebytes([0xAB] * 3)
	time.sleep(0.001)

