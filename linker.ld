/* The bootloader will look at this image and start execution at the symbol
   designated as the entry point. */
ENTRY(main)

PHDRS 
{
	boot PT_NULL;
	text PT_LOAD;
	data PT_LOAD;
}

/* Tell where the various sections of the object files will be put in the final
   kernel image. */
SECTIONS
{
	. = 0x7E00;

	.boot_text BLOCK(512) : ALIGN(1) {
		*(.boot.start)
		*(.boot.text)
	} :boot
	.boot_data BLOCK(1) : ALIGN(1)  {
		*(.boot.data)
	}
	.boot_bss BLOCK(1) : ALIGN(1)  {
		*(.boot.bss)
	}

	. = 1M;

	/* First put the multiboot header, as it is required to be put very early
	   in the image or the bootloader won't recognize the file format.
	   Next we'll put the .text section. */

	.text BLOCK(4K) : ALIGN(4K)
	{
		*(.text)
	} : text

	/* Read-only data. */
	.rodata BLOCK(4K) : ALIGN(4K)
	{
		*(.rodata)
	}

	/* Read-write data (initialized) */
	.data BLOCK(4K) : ALIGN(4K)
	{
		*(.data)
	} : data

	/* Read-write data (uninitialized) and stack */
	.bss BLOCK(4K) : ALIGN(4K)
	{
		*(COMMON)
		*(.bss)
	}

	/* The compiler may produce other sections, by default it will put them in
	   a segment with the same name. Simply add stuff here as needed. */
}