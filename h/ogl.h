
/*--   ogl.h -- Header for ogl.c -- which see.				*/
/* This file is formatted for emacs' outline-minor-mode.		*/
#ifndef INCLUDED_OGL_H
#define INCLUDED_OGL_H



/************************************************************************/
/*-    #includes							*/
/************************************************************************/



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Parameters for ogl_Select_OpenGL_Access_Level(): */
#define OGL_NO_OPENGL		0
#define OGL_AVATAR_OPENGL	1
#define OGL_UNRESTRICTED_OPENGL	2

/************************************************************************/
/*-    types								*/
/************************************************************************/



/************************************************************************/
/*-    externs								*/
/************************************************************************/

extern void   ogl_Startup( void              );
extern void   ogl_Linkup(  void              );
extern void   ogl_Shutdown(void              );

extern Obj_A_Module_Summary  ogl_Module_Summary;

extern int    ogl_Have_OpenGL_Support(void);
extern void   ogl_Select_OpenGL_Access_Level( Vm_Int );


/************************************************************************/
/*-    File variables							*/
/************************************************************************/
#endif /* INCLUDED_OGL_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

