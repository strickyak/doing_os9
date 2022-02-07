import RPi.GPIO as G
import time
import spidev
bus = 0
device = 0
spi = spidev.SpiDev()
spi.open(bus, device)
spi.max_speed_hz = 5000

# help(spi)
print(dir(spi))
print(spi.max_speed_hz)
print(spi.mode)

CMD_WRITE = 0xF0
CMD_READ = 0x0F

Pin = 11
G.setmode(G.BOARD)
G.setup(Pin, G.OUT)
G.output(Pin, G.HIGH)
G.output(Pin, G.LOW)
G.output(Pin, G.HIGH)

while True:
	spi.writebytes([CMD_WRITE, 0x00, 0x01, 0xAB])
	print(spi.xfer([CMD_READ, 0x00, 0x01]))
	time.sleep(1)


#while True:
#	spi.writebytes([0xAB] * 3)
#	time.sleep(0.001)

#while True:
#	G.output(Pin, G.HIGH)
#	time.sleep(0.02)
#	G.output(Pin, G.LOW)
#	time.sleep(0.08)
