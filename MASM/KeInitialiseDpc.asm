VOID KeInitializeDpc(
	_Out_    PRKDPC             Dpc,
	_In_     PKDEFERRED_ROUTINE DeferredRoutine,
	_In_opt_ PVOID              DeferredContext
);

KDPC
	+0x000 Type             : UChar
	+0x001 Importance       : UChar
	+0x002 Number           : Uint2B
	+0x004 DpcListEntry     : _LIST_ENTRY
	+0x00c DeferredRoutine  : Ptr32     void
	+0x010 DeferredContext  : Ptr32 Void
	+0x014 SystemArgument1  : Ptr32 Void
	+0x018 SystemArgument2  : Ptr32 Void
	+0x01c DpcData          : Ptr32 Void

; Function prologue
81a41776 8bff            mov     edi,edi
81a41778 55              push    ebp
81a41779 8bec            mov     ebp,esp
; (Parameter) Store pointer to KDPC struct in EAX
81a4177b 8b4508          mov     eax, dword ptr [ebp+8]
; (Parameter) Store pointer to CustomDpc routine in ECX
81a4177e 8b4d0c          mov     ecx, dword ptr [ebp+0Ch]
; Initialize KDPC struct DpcData field to NULL
81a41781 83601c00        and     dword ptr [eax+1Ch],0
; Store CustomDpc routine pointer (we got as a parameter)
; in KDPC struct DeferredRoutine field
81a41785 89480c          mov     dword ptr [eax+0Ch],ecx
; (Parameter) Store DeferredContext value to pass to CustomDpc in ECX
81a41788 8b4d10          mov     ecx,dword ptr [ebp+10h]
; Set KDPC Type field to 0x13
81a4178b c60013          mov     byte ptr [eax],13h
; Set KDPC Importance field to 1
81a4178e c6400101        mov     byte ptr [eax+1],1
; Set KDPC Number field to  0
81a41792 66c740020000    mov     word ptr [eax+2],0
; Set KDPC DeferredContext field to the parameter we were passed as a parameter
81a41798 894810          mov     dword ptr [eax+10h],ecx
; Restore base pointer
81a4179b 5d              pop     ebp
; Return and pop 3 parameters off stack
81a4179c c20c00          ret     0Ch

; Decompiled to C
void KeInitializeDpc(KDPC *kdpc, KDEFERRED_ROUTINE *routine, void *context) {
	kdpc->DpcData = NULL;
	kdpc->DeferredRoutine = routine;
	kdpc->Type = 19;
	kdpc->Importance = 1
	kdpc->Number = 0;
	kdpc->DeferredContext = context;
}
