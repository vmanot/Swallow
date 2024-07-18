//
//  DynamicLinkEditor.ImageManager.swift
//  DynamicLinkEditor.ImageManager
//
//  Created by John Holdsworth on 19/04/2021.
//  Copyright © 2020 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/DynamicLinkEditor.ImageManager
//  $Id: //depot/DynamicLinkEditor.ImageManager/Sources/DynamicLinkEditor.ImageManagerC/DynamicLinkEditor.ImageManagerC.c#11 $
//
//  Provides state for a symbol table iterator.
//

#if __has_include(<mach-o/dyld.h>)
#include "_init_dyld_image_symbol_iterator.h"
#include <string.h>

// Derived from: https://stackoverflow.com/questions/20481058/find-pathname-from-dlopen-handle-on-osx

void _init_dyld_image_symbol_iterator(const mach_header_t *header,
                                      struct _dyld_image_symbol_iterator *state) {
    state->next_symbol = 0;
    segment_command_t *seg_text = NULL;
    segment_command_t *seg_linkedit = NULL;
    struct symtab_command *symtab = NULL;
    struct load_command *cmd =
    (struct load_command *)((intptr_t)header + sizeof(mach_header_t));
    
    for (uint32_t i = 0; i < header->ncmds; i++,
         cmd = (struct load_command *)((intptr_t)cmd + cmd->cmdsize)) {
        switch(cmd->cmd) {
            case LC_SEGMENT:
            case LC_SEGMENT_64:
                if (!strcmp(((segment_command_t *)cmd)->segname, SEG_TEXT))
                    seg_text = (segment_command_t *)cmd;
                else if (!strcmp(((segment_command_t *)cmd)->segname, SEG_LINKEDIT))
                    seg_linkedit = (segment_command_t *)cmd;
                break;
                
            case LC_SYMTAB:
                symtab = (struct symtab_command *)cmd;
                break;
        }
    }
    
    if (symtab && seg_text && seg_linkedit) {
        state->symbol_count = symtab->nsyms;
        intptr_t file_slide = ((intptr_t)seg_linkedit->vmaddr -
                               (intptr_t)seg_text->vmaddr) - seg_linkedit->fileoff;
        state->symbols = (nlist_t *)((intptr_t)header +
                                     (symtab->symoff + file_slide));
        state->strings_base = (const char *)header +
        (symtab->stroff + file_slide);
        state->address_base = (intptr_t)header - seg_text->vmaddr;
    }
}

void *_dyld_image_symbol_iterator_self_caller_address(void) {
    return __builtin_return_address(2);
}
#endif
