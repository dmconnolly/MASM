NTKERNELAPI VOID KeInitializeApc(
    PKAPC Apc,
    PKTHREAD Thread,
    KAPC_ENVIRONMENT Environment,
    PKKERNEL_ROUTINE KernelRoutine,
    PKRUNDOWN_ROUTINE RundownRoutine,
    PKNORMAL_ROUTINE NormalRoutine,
    KPROCESSOR_MODE ProcessorMode,
    PVOID NormalContext
);

ntdll!_KAPC
   +0x000 Type             : UChar
   +0x001 SpareByte0       : UChar
   +0x002 Size             : UChar
   +0x003 SpareByte1       : UChar
   +0x004 SpareLong0       : Uint4B
   +0x008 Thread           : Ptr32 _KTHREAD
   +0x00c ApcListEntry     : _LIST_ENTRY
   +0x014 KernelRoutine    : Ptr32     void
   +0x018 RundownRoutine   : Ptr32     void
   +0x01c NormalRoutine    : Ptr32     void
   +0x020 NormalContext    : Ptr32 Void
   +0x024 SystemArgument1  : Ptr32 Void
   +0x028 SystemArgument2  : Ptr32 Void
   +0x02c ApcStateIndex    : Char
   +0x02d ApcMode          : Char
   +0x02e Inserted         : UChar

; Function prologue
81ab3956 8bff            mov     edi,edi
81ab3958 55              push    ebp
81ab3959 8bec            mov     ebp,esp

; (Parameter) Store APC pointer in EAX
81ab395b 8b4508          mov     eax,dword ptr [ebp+8]
; (Parameter) Store APC_ENVIRONMENT in EDX
81ab395e 8b5510          mov     edx,dword ptr [ebp+10h]
; Check if APC_ENVIRONMENT is 2
81ab3961 83fa02          cmp     edx,2
; (Parameter) Store THREAD in ECX
81ab3964 8b4d0c          mov     ecx,dword ptr [ebp+0Ch]
; Set APC Type field to 0x12
81ab3967 c60012          mov     byte ptr [eax],12h
; Set APC Size field to 0x30
81ab396a c6400230        mov     byte ptr [eax+2],30h
; If APC_ENVIRONMENT is not 2
	; jump to 0x81ab3976
	81ab396e 7506            jne     nt!KeInitializeApc+0x20 (81ab3976)
nt!KeInitializeApc+0x1a:
	; Else if APC_ENVIROMNENT is 2
	; Set DL to THREAD ApcStateIndex field
	81ab3970 8a9130010000    mov     dl,byte ptr [ecx+130h]

nt!KeInitializeApc+0x20:
; Set APC THREAD field to THREAD parameter
81ab3976 894808          mov     dword ptr [eax+8],ecx
; (Parameter) Store KERNEL_ROUTINE pointer in ECX
81ab3979 8b4d14          mov     ecx,dword ptr [ebp+14h]
; Set APC KERNEL_ROUTINE field to KERNEL_ROUTINE parameter
81ab397c 894814          mov     dword ptr [eax+14h],ecx
; (Parameter) Store RUNDOWN_ROUTINE in ECX
81ab397f 8b4d18          mov     ecx,dword ptr [ebp+18h]
; Set APC ApcStateIndex to APC_ENVIRONMENT
81ab3982 88502c          mov     byte ptr [eax+2Ch],dl
; Set APC RundownRoutine field to RUNDOWN_ROUTINE parameter
81ab3985 894818          mov     dword ptr [eax+18h],ecx
; (Parameter) Store NORMAL_ROUTINE in ECX
81ab3988 8b4d1c          mov     ecx,dword ptr [ebp+1Ch]
; Set EDX to 0
81ab398b 33d2            xor     edx,edx
; Check if NORMAL_ROUTINE parameter is NULL
81ab398d 3bca            cmp     ecx,edx
; Set APC NormalRoutine field to NORMAL_ROUTINE parameter
81ab398f 89481c          mov     dword ptr [eax+1Ch],ecx
; If NORMAL_ROUTINE is NULL jump to 0x81ab39a2
81ab3992 740e            je      nt!KeInitializeApc+0x4c (81ab39a2)
nt!KeInitializeApc+0x3e:
	; If NORMAL_ROUTINE is not NULL
	; (Parameter) store PROCESSOR_MODE in CL
	81ab3994 8a4d20          mov     cl,byte ptr [ebp+20h]
	; Set APC ApcMode field to PROCESSOR_MODE parameter
	81ab3997 88482d          mov     byte ptr [eax+2Dh],cl
	; (Parameter) Store VOID *NormalContext in ECX
	81ab399a 8b4d24          mov     ecx,dword ptr [ebp+24h]
	; Set APC NormalContext field to NormalContext parameter
	81ab399d 894820          mov     dword ptr [eax+20h],ecx
	; Jump to 0x81ab39a8
	81ab39a0 eb06            jmp     nt!KeInitializeApc+0x52 (81ab39a8)

nt!KeInitializeApc+0x4c:
	; If NORMAL_ROUTINE is NULL
	; Set APC ApcMode field to 0
	81ab39a2 88502d          mov     byte ptr [eax+2Dh],dl
	; Set APC NormalContext field to NULL
	81ab39a5 895020          mov     dword ptr [eax+20h],edx

nt!KeInitializeApc+0x52:
; Set APC Inserted field to 0
81ab39a8 88502e          mov     byte ptr [eax+2Eh],dl

; Restore stack pointer
81ab39ab 5d              pop     ebp
; Pop 8 parameters off the stack
81ab39ac c22000          ret     20h

void KeInitialiseApc(
    APC *Apc,
    THREAD *Thread,
    APC_ENVIRONMENT Environment,
    KERNEL_ROUTINE *KernelRoutine,
    KRUNDOWN_ROUTINE *RundownRoutine,
    KNORMAL_ROUTINE *NormalRoutine,
    ROCESSOR_MODE *ProcessorMode,
    VOID *NormalContext)
{
    Apc->Type = 0x12;
    Apc->Size = 0x30;

    if(Environment == 2) {
        Apc->ApcStateIndex = Thread->ApcStateIndex;
    } else {
        Apc->ApcStateIndex = Environment;
    }

    Apc->Thread = Thread;
    Apc->KernelRoutine = KernelRoutine;
    Apc->RundownRoutine = RundownRoutine;

    if(NormalRoutine) {
        Apc->ApcMode = ProcessorMode;
        Apc->NormalContext = NormalContext;
    } else {
        Apc->ApcMode = 0;
        Apc->NormalContext = NULL;
    }

    Apc->Inserted = 0;
}
