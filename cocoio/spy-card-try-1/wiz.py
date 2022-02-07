import RPi.GPIO as G
import time
import spidev
bus = 0
device = 0
spi = spidev.SpiDev()
spi.open(bus, device)
spi.max_speed_hz = 5000
spi.mode = 0

print("hz", spi.max_speed_hz)
print("mode", spi.mode)

CMD_WRITE = 0xF0
CMD_READ = 0x0F

while True:
	spi.writebytes([CMD_WRITE, 0x00, 0x00, 0x80])
	for i in range(4):
		print('  ', i+1, end=':')
		spi.writebytes([CMD_WRITE, 0x00, i+1, 64+i])
		print(spi.xfer([CMD_READ, 0x00, i+1, 255]), end=';')
	print(' sleep')
	time.sleep(0.5)

def Reset():
	Pin = 11
	G.setmode(G.BOARD)
	G.setup(Pin, G.OUT)
	G.output(Pin, G.HIGH)
	G.output(Pin, G.LOW)
	G.output(Pin, G.HIGH)

def Toggle():
	while True:
		G.output(Pin, G.HIGH)
		time.sleep(0.02)
		G.output(Pin, G.LOW)
		time.sleep(0.08)
