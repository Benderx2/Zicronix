;; IDT - Interrupt Descriptor Tables.
;; Note that the first 32 entries are reserved, they are 
;; used by the CPU in case of fatal error stuff like #GP, TripleF,
;; DoubleF's, etc.
;; Everything is mostly the same format, like this :
;; dw INT_HANDLER
;; dw CODE_SEL
;; db 0x00
;; db 0x8E
;; dw 0
;; This table is gonna kick ass, it's huuuuuggeeeeeeeeeeee.
;; BTW Good News. Only the first 32 exceptions are marked.
;; Rest all are unhandled 8)
use32
idt:
	.entry_0:
		;; int 0 - Divide by zero error
		dw cpu32_div_by_zero
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_1:
		;; CPU Break Point
		dw cpu32_breakpoint
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_2:
		;; CPU NMI
		dw cpu32_NMI
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_3:
		;; CPU Break Point
		dw cpu32_breakpoint
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_4:
		;; CPU Overflow Exception
		dw cpu32_overflow
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_5:
		;; Bound Range Exceeded
		dw cpu32_bound_range
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_6:
		;; Invalid OpCode
		dw cpu32_opcode
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_7:
		;; Device Not available
		dw cpu32_device_excep
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_8:
		;; Double Fault :P
		dw double_fault
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_9:
		;; Coprocessor Segment Overrun
		dw co_seg_ovrn
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_10:
		;; Invalid TSS
		dw cpu32_invalid_TSS
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_11:
		;; Segment not present
		dw cpu32_invalid_seg
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_12:
		;; Stack Segment Fault
		dw stack_seg_fault
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_13:
		;; ALL HAIL GREAT GENERAL PROTECTION FAULT!
		;; HANDLE WITH CARE!
		dw gen_protect_fault
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_14:
		;; AND ONE MORE CHIEF-GUEST!
		;; PAGE-FAULT!
		dw page_fault
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_15:
		;; Reserved
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_16:
		;; x87 Floating Point Exception
		;; We need this, as I make heavy use of FPU
		dw x87_fpu_error
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_17:
		;; Alignment Check
		dw cpu32_align_check
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_18:
		;; Machine Check
		dw cpu32_machine_check
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_19:
		;; SIMD Machine Floating Point Exception
		dw simd_fpu_excep
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_20:
		;; Virtualization Exception
		;; Seriously? Who cares?
		dw virtual_excep
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_21_29:
		;; All these interrupts are reserved
		;;
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
		;;
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
		;;
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
		;;
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
		;;
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
		;;
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
		;;
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
		;;
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
		;;
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
		;;
	.entry_30:
		;; Security Exception
		dw cpu32_security_excep
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_31:
		;; Reserved
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	;; Well we've finally cleared all the reserved interrupts, now the next 224 entries
	;; can be defined by us. Happy?
	;; Note However, till entry 47, we've IRQ exceptions so we will not use them.
	.entry_32:
		dw pit_timer
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_33:
		;; This is for a keyboard Interrupt.
		dw keyboard_handler
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_34:
		;; IRQ 2
		dw irq2
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_35:
		;; IRQ 3
		dw irq3
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_36:
		;; IRQ 4
		dw irq4
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_37:
		;; IRQ 5
		dw irq5
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_38:
		;; IRQ 6
		dw irq6
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_39:
		;; IRQ 7
		dw irq7
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_40:
		;; IRQ 8
		dw irq8
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_41:
		;; IRQ 9
		dw irq9
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_42:
		;; IRQ A
		dw irqa
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_43:
		;; IRQ B
		dw irqb
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_44:
		;; IRQ C
		dw irqc
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_45:
		;; IRQ D
		dw irqd
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_46:
		;; IRQ E
		dw irqe
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_47:
		;; IRQ F
		dw irqf
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
		;; All IRQs in their correct places cheif!
		; The next entries are all unhandled. 
		;; May use them for System API and stuff like that
		;; INT (0x30) - SYS_API_32
		;; Defines the System API
		;; See ~/Bendex/api/api32.asm
	.entry_48:
		dw sys_api_32
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
		;; Disk API - Int 0x31
	.entry_49:
		dw fat_api_32
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_50:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_51:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_52:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_53:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_54:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_55:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_56:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_57:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_58:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_59:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_60:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_61:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_62:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_63:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_64:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_65:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_66:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_67:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_68:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_69:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_70:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_71:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_72:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_73:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_74:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_78:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_79:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_80:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_81:
		dw app_services
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_82:
		dw app_services
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_83:
		dw app_services
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_84:
		dw app_services
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_85:
		dw app_services
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_86:
		dw app_services
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_87:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_88:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_89:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_90:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_91:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_92:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_93:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_94:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_95:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_96:
		;; Can also be used as a CMOS-Time-CLock IRQ
		dw pit_timer
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_97:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_98:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_99:
		dw app_services
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	;; 100! I rock!
	;; 156 to GO!
	;; Lol this is for the apps
	.entry_100:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_101:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_102:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_103:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_104:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_105:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_106:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_107:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_108:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_109:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_110:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_111:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_112:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_113:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_114:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_115:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_116:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_117:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_118:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_119:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_120:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_121:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_122:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_123:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_124:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_125:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_126:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_127:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	;; Half Way there!
	.entry_128:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_129:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_130:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_131:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_132:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_133:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_134:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_135:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_136:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_137:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_138:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_139:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_140:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_141:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_142:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_143:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_144:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_145:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_146:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_147:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_148:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_149:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	; One-And a half century. Cricket Anyone?
	.entry_150:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_151:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_152:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_153:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_154:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_155:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_156:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_157:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_158:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_159:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_160:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_161:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_162:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_163:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_164:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_165:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_166:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_167:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_168:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_169:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_170:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_171:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_172:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_173:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_174:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_175:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_176:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_177:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_178:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_179:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_180:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_181:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_182:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_183:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_184:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_185:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_186:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_187:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_188:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_189:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_190:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_191:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_192:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_193:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_194:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_195:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_196:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_197:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_198:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_199:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_200:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	;; Woo! 200! 
	.entry_201:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_202:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_203:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_204:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_205:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_206:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_207:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_208:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_209:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_210:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_211:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_212:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_213:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_214:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_215:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_216:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_217:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_218:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_219:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_220:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_221:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_222:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_223:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_224:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_225:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_226:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_227:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_228:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_229:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_230:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_231:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_232:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_233:	
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_234:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_235:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_236:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_237:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_238:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_239:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_240:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_241:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_242:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_243:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_244:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_245:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_246:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_247:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_248:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_249:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_250:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	;; 5 MORE TO GO!!!!! F@@@
	.entry_251:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_252:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_253:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_254:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	.entry_255:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
	; HOLY F@@@ I CAN'T BELIEVE WE DID IT!
	; FINALLY
	.entry_256:
		dw unhandled_isr
		dw CODE_SEL
		db 0x00
		db 0x8E
		dw 0
;; End of IDT
.END_OF_IDT:

IDT_DESC:
	dw idt.END_OF_IDT - idt - 1
	dd idt