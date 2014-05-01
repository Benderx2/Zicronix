// ZNU Lib
// SmallerC library for ZNU Application and programs
// (C) Bender, 2014-2015 under 2-clause BSD license
// I plan to add PCI Read functions later :)
void pci_write_8(uint8_t pci_reg, uint32_t pci_device)
{
	asm("mov ah, 0x10");
	asm("mov dl, [ebp + 8]");
	asm("mov eax, [ebp + 16]");
	asm("int 0x50");
}
void pci_write_16(uint16_t pci_reg, uint32_t pci_device)
{
	asm("mov ah, 0x10");
	asm("mov dx, [ebp + 8]");
	asm("mov eax, [ebp + 16]");
	asm("int 0x50");
}
void pci_write_32(uint32_t pci_reg, uint32_t pci_device)
{
	asm("mov ah, 0x10");
	asm("mov edx, [ebp + 8]");
	asm("mov eax, [ebp + 16]");
	asm("int 0x50");
}
