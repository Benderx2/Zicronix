get_cpu_string:
   use16
   mov eax, 80000002h       
   cpuid
   stosd                   
   mov eax, ebx
   stosd                    
   mov eax, ecx
   stosd                    
   mov eax, edx
   stosd                  
   mov eax, 80000003h          
   cpuid
   stosd                 
   mov eax, ebx
   stosd                   
   mov eax, ecx
   stosd                   
   mov eax, edx
   stosd                    
   mov eax, 80000004h           
   cpuid
   stosd                   
   mov eax, ebx
   stosd                    
   mov eax, ecx
   stosd                   
   mov eax, edx
   stosd                   
   ret