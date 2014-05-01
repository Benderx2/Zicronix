;; multitasker BS.
struct task name, address
{	
	.
}
;; maximum number of tasks = 0xFF (256, do we want to overload the CPU?)
define MAX_TASKS 0xFF
tasker_data:
.number_of_tasks: db 0x00
;; okay check if we have any tasks pending
check_for_tasks:
	cmp byte [tasker_data.number_of_tasks], 0x00
	je .no_task
	mov ax, 1
	ret
.no_task:
	mov ax, -1
	ret
;; create task
;; creates a task
;; esi: pointer to task
create_task:
	