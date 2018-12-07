AS = as
LD = ld
COPY = objcopy
DUMP = objdump

all: forth
	@$(COPY) -j.text -j.rodata -j.data -O binary $< $<.bin
	@chmod -x $<.bin
	@$(DUMP) -S $< > list.txt
	@$(DUMP) -h -j.text -j.rodata -j.data $<

forth: forth.o
	$(LD) $< -o $@

%.o: %.S
	$(AS) -g -ahlsm $< -o $@ > $(*).lst

clean:
	rm -f *.txt *.lst *.bin
	rm -f *.o forth
