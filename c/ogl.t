@example  @c
/*    ogl.c -- OpenGL support for Muq.					*/
/* {{{ This file is formatted for outline-minor-mode in emacs19.	*/
/*-^C^O^A shows All of file.						*/
/* ^C^O^Q Quickfolds entire file. (Leaves only top-level headings.)	*/
/* ^C^O^T hides all Text. (Leaves all headings.)			*/
/* ^C^O^I shows Immediate children of node.				*/
/* ^C^O^S Shows all of a node.						*/
/* ^C^O^D hiDes all of a node.						*/
/* ^HFoutline-mode gives more details.					*/
/* (Or do ^HI and read emacs:outline mode.)				*/
/* }}} */

/************************************************************************/
/* {{{   Dedication and Copyright.					*/
/************************************************************************/

/************************************************************************/
/*									*/
/*		For Firiss:  Aefrit, a friend.				*/
/*									*/
/************************************************************************/

/************************************************************************/
/* Author:       Jeff Prothero						*/
/* Created:      99Aug29						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 2000, by Jeff Prothero.				*/
/*									*/
/* This program is free software; you may use, distribute and/or modify	*/
/* it under the terms of the GNU Library General Public License as      */
/* published by	the Free Software Foundation; either version 2, or (at  */
/* your option)	any later version FOR NONCOMMERCIAL PURPOSES.		*/
/*									*/
/*  COMMERCIAL operation allowable at $100/CPU/YEAR.			*/
/*  COMMERCIAL distribution (e.g., on CD-ROM) is UNRESTRICTED.		*/
/*  Other commercial arrangements NEGOTIABLE.				*/
/*  Contact cynbe@@eskimo.com for a COMMERCIAL LICENSE.			*/
/*									*/
/*   This program is distributed in the hope that it will be useful,	*/
/*   but WITHOUT ANY WARRANTY; without even the implied warranty of	*/
/*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the	*/
/*   GNU Library General Public License for more details.		*/
/*									*/
/*   You should have received the GNU Library General Public License	*/
/*   along with this program (COPYING.LIB); if not, write to:		*/
/*      Free Software Foundation, Inc.					*/
/*      675 Mass Ave, Cambridge, MA 02139, USA.				*/
/*									*/
/* Jeff Prothero DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,	*/
/* INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN	*/
/* NO EVENT SHALL JEFF PROTHERO BE LIABLE FOR ANY SPECIAL, INDIRECT OR	*/
/* CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS	*/
/* OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,		*/
/* NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION	*/
/* WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.			*/
/*									*/
/* Please send bug reports/fixes etc to bugs@@muq.org.			*/
/************************************************************************/

/* }}} */

/************************************************************************/
/* {{{  Quote								*/
/************************************************************************/

/************************************************************************

  "Accursed be the man who withholds his sword from shedding the
   blood of the enemies of Christ.  Every believer must wash his
   hands in that blood."
           -- tract widely circulated in Bohemia ca 1420
                  (Ref: History in Three Keys p89)

 ************************************************************************/

/* }}} */

/************************************************************************/
/* {{{  Overview							*/
/************************************************************************/

/************************************************************************


 ************************************************************************/


/* }}} */

/************************************************************************/
/* {{{  Notes and references						*/
/************************************************************************/

/************************************************************************

	If the performance claims are anything like they claim (modulo the
	lack of GL support), I could see building an interesting client out
	of this:

	  http://marangoni.lmm.jussieu.fr/gts/

	--<cut>--
	GTS stands for the GNU Triangulated Surface Library. It is an Open
	Source Free Software Library intended to provide a set of useful
	functions to deal with 3D surfaces meshed with interconnected
	triangles. The source code is available free of charge under the
	Free Software LGPL license.

	The code is written entirely in C with an object-oriented approach
	based mostly on the design of GTK+. Careful attention is paid to
	performance related issues as the initial goal of GTS is to provide
	a simple and efficient library to scientists dealing with 3D
	computational surface meshes.
	--<cut>--

	--
	J C Lawrence                                 Home: claw@kanga.nu



    Oh, interesting thing: Have you heard of fltk?

    Check out: http://www.fltk.org/doc/common.html#common

    I just found out about it today, as someone else was using it with
    opengl.. They said that glut didn't do enough as far as other widgets
    were needed, and fltk gave them widgets.

    It looks NICE... and it has opengl integration... Too bad its support for
    images is lacking.... I do need to learn gtk.
            (Scot Crosby)


 ************************************************************************/


/* }}} */

/************************************************************************/
/* {{{  #includes							*/
/************************************************************************/

#include "All.h"


/* }}} */

/************************************************************************/
/* {{{  #defines							*/
/************************************************************************/

/* Tunable parameters: */

/* Stuff you shouldn't need to fiddle with: */


/* }}} */

/************************************************************************/
/* {{{  Statics								*/
/************************************************************************/

static void ogl_startup(void);

static Job_Slow_Prim job_No_OpenGL_Table3[     JOB_SLOW_TABLE_MAX ];
static Job_Slow_Prim job_No_OpenGL_Table4[     JOB_SLOW_TABLE_MAX ];

static Job_Slow_Prim job_No_Window_Table3[     JOB_SLOW_TABLE_MAX ];
static Job_Slow_Prim job_No_Window_Table4[     JOB_SLOW_TABLE_MAX ];

static Job_Slow_Prim job_Avatar_OpenGL_Table3[ JOB_SLOW_TABLE_MAX ];
static Job_Slow_Prim job_Avatar_OpenGL_Table4[ JOB_SLOW_TABLE_MAX ];



/* }}} */

/************************************************************************/
/* {{{  Globals								*/
/************************************************************************/

static void ogl_doTypes(void){}
Obj_A_Module_Summary ogl_Module_Summary = {
   "ogl",
    ogl_doTypes,
    ogl_Startup,
    ogl_Linkup,
    ogl_Shutdown,
};


/* }}} */

/************************************************************************/
/* {{{  ogl_Need_Avatar_OpenGL						*/
/************************************************************************/

static void
ogl_Need_Avatar_OpenGL(
    void
) {
    MUQ_WARN("Must have me.avatarOpenGL set non-nil to invoke this fn.");
}

/* }}} */

/************************************************************************/
/* {{{  ogl_Need_Unrestricted_OpenGL					*/
/************************************************************************/

static void
ogl_Need_Unrestricted_OpenGL(
    void
) {
    MUQ_WARN("Must have me.unrestrictedOpenGL set non-nil to invoke this fn.");
}

/* }}} */

/************************************************************************/
/* {{{  ogl_Need_Window							*/
/************************************************************************/

static void
ogl_Need_Window(
    void
) {
    MUQ_WARN("Must call glutCreateWindow before invoking this fn.");
}

/* }}} */


/************************************************************************/
/* {{{  ogl_Open_Window_Fn_Filter					*/
/************************************************************************/

static Job_Slow_Prim
ogl_Open_Window_Fn_Filter(
    Job_Slow_Prim fn
) {
    if (fn==job_P_Glut_Init_Display_Mode)   return fn;
    if (fn==job_P_Glut_Create_Window)       return fn;
    return ogl_Need_Window;
}

/************************************************************************/
/* {{{  ogl_Avatar_Fn_Filter						*/
/************************************************************************/

static Job_Slow_Prim
ogl_Avatar_Fn_Filter(
    Job_Slow_Prim fn
) {
    /* List functions allowed for avatars: */
    if (fn==job_P_Glu_Scale_Image)  		return fn;
    if (fn==job_P_Glu_Build1D_Mipmaps)     	return fn;
    if (fn==job_P_Glu_Build2D_Mipmaps)     	return fn;
    if (fn==job_P_Glu_New_Quadric)     		return fn;
    if (fn==job_P_Glu_Delete_Quadric)     	return fn;
    if (fn==job_P_Glu_Quadric_Draw_Style)     	return fn;
    if (fn==job_P_Glu_Quadric_Orientation)     	return fn;
    if (fn==job_P_Glu_Quadric_Normals)     	return fn;
    if (fn==job_P_Glu_Quadric_Texture)     	return fn;
    if (fn==job_P_Glu_Cylinder)     		return fn;
    if (fn==job_P_Glu_Sphere)     		return fn;
    if (fn==job_P_Glu_Disk)     		return fn;
    if (fn==job_P_Glu_Partial_Disk)     	return fn;
    if (fn==job_P_Glu_New_Nurbs_Renderer)     	return fn;
    if (fn==job_P_Glu_Delete_Nurbs_Renderer)    return fn;
    if (fn==job_P_Glu_Load_Sampling_Matrices)   return fn;
    if (fn==job_P_Glu_Nurbs_Property)     	return fn;
    if (fn==job_P_Glu_Get_Nurbs_Property)     	return fn;
    if (fn==job_P_Glu_Begin_Curve)     		return fn;
    if (fn==job_P_Glu_End_Curve)     		return fn;
    if (fn==job_P_Glu_Nurbs_Curve)     		return fn;
    if (fn==job_P_Glu_Begin_Surface)     	return fn;
    if (fn==job_P_Glu_End_Surface)     		return fn;
    if (fn==job_P_Glu_Nurbs_Surface)     	return fn;
    if (fn==job_P_Glu_Begin_Trim)     		return fn;
    if (fn==job_P_Glu_End_Trim)     		return fn;
    if (fn==job_P_Glu_Pwl_Curve)     		return fn;
    if (fn==job_P_Glu_New_Tess)     		return fn;
    if (fn==job_P_Glu_Delete_Tess)     		return fn;
    if (fn==job_P_Glu_Begin_Polygon)     	return fn;
    if (fn==job_P_Glu_End_Polygon)     		return fn;
    if (fn==job_P_Glu_Next_Contour)     	return fn;
    if (fn==job_P_Glu_Tess_Vertex)     		return fn;
    if (fn==job_P_Glu_Get_String)     		return fn;
    if (fn==job_P_Glut_Set_Color)     		return fn;
    if (fn==job_P_Glut_Get_Color)     		return fn;
    if (fn==job_P_Glut_Get)     		return fn;
    if (fn==job_P_Glut_Device_Get)     		return fn;
    if (fn==job_P_Glut_Extension_Supported)     return fn;
    if (fn==job_P_Glut_Get_Modifiers)     	return fn;
    if (fn==job_P_Glut_Bitmap_Character)     	return fn;
    if (fn==job_P_Glut_Bitmap_Width)     	return fn;
    if (fn==job_P_Glut_Stroke_Character)     	return fn;
    if (fn==job_P_Glut_Stroke_Width)     	return fn;
    if (fn==job_P_Glut_Bitmap_Length)     	return fn;
    if (fn==job_P_Glut_Stroke_Length)     	return fn;
    if (fn==job_P_Glut_Wire_Sphere)     	return fn;
    if (fn==job_P_Glut_Solid_Sphere)     	return fn;
    if (fn==job_P_Glut_Wire_Cone)     		return fn;
    if (fn==job_P_Glut_Solid_Cone)     		return fn;
    if (fn==job_P_Glut_Wire_Cube)     		return fn;
    if (fn==job_P_Glut_Solid_Cube)     		return fn;
    if (fn==job_P_Glut_Wire_Torus)     		return fn;
    if (fn==job_P_Glut_Solid_Torus)     	return fn;
    if (fn==job_P_Glut_Wire_Dodecahedron)     	return fn;
    if (fn==job_P_Glut_Solid_Dodecahedron)     	return fn;
    if (fn==job_P_Glut_Wire_Teapot)     	return fn;
    if (fn==job_P_Glut_Solid_Teapot)     	return fn;
    if (fn==job_P_Glut_Wire_Octahedron)     	return fn;
    if (fn==job_P_Glut_Solid_Octahedron)     	return fn;
    if (fn==job_P_Glut_Wire_Tetrahedron)     	return fn;
    if (fn==job_P_Glut_Solid_Tetrahedron)     	return fn;
    if (fn==job_P_Glut_Wire_Icosahedron)     	return fn;
    if (fn==job_P_Glut_Solid_Icosahedron)     	return fn;
    if (fn==job_P_Gl_Cull_Face)     		return fn;
    if (fn==job_P_Gl_Front_Face)     		return fn;
    if (fn==job_P_Gl_Point_Size)     		return fn;
    if (fn==job_P_Gl_Line_Width)     		return fn;
    if (fn==job_P_Gl_Line_Stipple)     		return fn;
    if (fn==job_P_Gl_Polygon_Mode)     		return fn;
    if (fn==job_P_Gl_Polygon_Offset)     	return fn;
    if (fn==job_P_Gl_Polygon_Stipple)     	return fn;
    if (fn==job_P_Gl_Get_Polygon_Stipple)     	return fn;
    if (fn==job_P_Gl_Edge_Flag)     		return fn;
    if (fn==job_P_Gl_Edge_Flagv)     		return fn;
    if (fn==job_P_Gl_Enable)     		return job_P_Gla_Enable;
    if (fn==job_P_Gl_Disable)     		return job_P_Gla_Disable;
    if (fn==job_P_Gl_Is_Enabled)     		return fn;
    if (fn==job_P_Gl_Get_Boolean)     		return fn;
    if (fn==job_P_Gl_Get_Double)     		return fn;
    if (fn==job_P_Gl_Get_Float)     		return fn;
    if (fn==job_P_Gl_Get_Integer)     		return fn;
    if (fn==job_P_Gl_Get_Boolean_Block)     	return fn;
    if (fn==job_P_Gl_Get_Double_Block)     	return fn;
    if (fn==job_P_Gl_Get_Float_Block)     	return fn;
    if (fn==job_P_Gl_Get_Integer_Block)     	return fn;
    if (fn==job_P_Gl_Get_Booleanv)     		return fn;
    if (fn==job_P_Gl_Get_Doublev)     		return fn;
    if (fn==job_P_Gl_Get_Floatv)     		return fn;
    if (fn==job_P_Gl_Get_Integerv)     		return fn;
    if (fn==job_P_Gl_Get_Error)     		return fn;
    if (fn==job_P_Gl_Get_String)     		return fn;
    if (fn==job_P_Gl_Begin)     		return fn;
    if (fn==job_P_Gl_End)     			return fn;
    if (fn==job_P_Gl_Vertex2D)			return fn;
    if (fn==job_P_Gl_Vertex2F)			return fn;
    if (fn==job_P_Gl_Vertex2I)			return fn;
    if (fn==job_P_Gl_Vertex2S)			return fn;
    if (fn==job_P_Gl_Vertex3D)			return fn;
    if (fn==job_P_Gl_Vertex3F)			return fn;
    if (fn==job_P_Gl_Vertex3I)			return fn;
    if (fn==job_P_Gl_Vertex3S)			return fn;
    if (fn==job_P_Gl_Vertex4D)			return fn;
    if (fn==job_P_Gl_Vertex4F)			return fn;
    if (fn==job_P_Gl_Vertex4I)			return fn;
    if (fn==job_P_Gl_Vertex4S)			return fn;
    if (fn==job_P_Gl_Vertex2Dv)			return fn;
    if (fn==job_P_Gl_Vertex2Fv)			return fn;
    if (fn==job_P_Gl_Vertex2Iv)			return fn;
    if (fn==job_P_Gl_Vertex2Sv)			return fn;
    if (fn==job_P_Gl_Vertex3Dv)			return fn;
    if (fn==job_P_Gl_Vertex3Fv)			return fn;
    if (fn==job_P_Gl_Vertex3Iv)			return fn;
    if (fn==job_P_Gl_Vertex3Sv)			return fn;
    if (fn==job_P_Gl_Vertex4Dv)			return fn;
    if (fn==job_P_Gl_Vertex4Fv)			return fn;
    if (fn==job_P_Gl_Vertex4Iv)			return fn;
    if (fn==job_P_Gl_Vertex4Sv)			return fn;
    if (fn==job_P_Gl_Normal3B)			return fn;
    if (fn==job_P_Gl_Normal3D)			return fn;
    if (fn==job_P_Gl_Normal3F)			return fn;
    if (fn==job_P_Gl_Normal3I)			return fn;
    if (fn==job_P_Gl_Normal3S)			return fn;
    if (fn==job_P_Gl_Normal3Bv)			return fn;
    if (fn==job_P_Gl_Normal3Dv)			return fn;
    if (fn==job_P_Gl_Normal3Fv)			return fn;
    if (fn==job_P_Gl_Normal3Iv)			return fn;
    if (fn==job_P_Gl_Normal3Sv)			return fn;
    if (fn==job_P_Gl_Color3B)			return fn;
    if (fn==job_P_Gl_Color3D)			return fn;
    if (fn==job_P_Gl_Color3F)			return fn;
    if (fn==job_P_Gl_Color3I)			return fn;
    if (fn==job_P_Gl_Color3S)			return fn;
    if (fn==job_P_Gl_Color3Ub)			return fn;
    if (fn==job_P_Gl_Color3Ui)			return fn;
    if (fn==job_P_Gl_Color3Us)			return fn;
    if (fn==job_P_Gl_Color4B)			return fn;
    if (fn==job_P_Gl_Color4D)			return fn;
    if (fn==job_P_Gl_Color4F)			return fn;
    if (fn==job_P_Gl_Color4I)			return fn;
    if (fn==job_P_Gl_Color4S)			return fn;
    if (fn==job_P_Gl_Color4Ub)			return fn;
    if (fn==job_P_Gl_Color4Ui)			return fn;
    if (fn==job_P_Gl_Color4Us)			return fn;
    if (fn==job_P_Gl_Color3Bv)			return fn;
    if (fn==job_P_Gl_Color3Dv)			return fn;
    if (fn==job_P_Gl_Color3Fv)			return fn;
    if (fn==job_P_Gl_Color3Iv)			return fn;
    if (fn==job_P_Gl_Color3Sv)			return fn;
    if (fn==job_P_Gl_Color3Ubv)			return fn;
    if (fn==job_P_Gl_Color3Uiv)			return fn;
    if (fn==job_P_Gl_Color3Usv)			return fn;
    if (fn==job_P_Gl_Color4Bv)			return fn;
    if (fn==job_P_Gl_Color4Dv)			return fn;
    if (fn==job_P_Gl_Color4Fv)			return fn;
    if (fn==job_P_Gl_Color4Iv)			return fn;
    if (fn==job_P_Gl_Color4Sv)			return fn;
    if (fn==job_P_Gl_Color4Ubv)			return fn;
    if (fn==job_P_Gl_Color4Uiv)			return fn;
    if (fn==job_P_Gl_Color4Usv)			return fn;
    if (fn==job_P_Gl_Tex_Coord1D)		return fn;
    if (fn==job_P_Gl_Tex_Coord1F)		return fn;
    if (fn==job_P_Gl_Tex_Coord1I)		return fn;
    if (fn==job_P_Gl_Tex_Coord1S)		return fn;
    if (fn==job_P_Gl_Tex_Coord2D)		return fn;
    if (fn==job_P_Gl_Tex_Coord2F)		return fn;
    if (fn==job_P_Gl_Tex_Coord2I)		return fn;
    if (fn==job_P_Gl_Tex_Coord2S)		return fn;
    if (fn==job_P_Gl_Tex_Coord3D)		return fn;
    if (fn==job_P_Gl_Tex_Coord3F)		return fn;
    if (fn==job_P_Gl_Tex_Coord3I)		return fn;
    if (fn==job_P_Gl_Tex_Coord3S)		return fn;
    if (fn==job_P_Gl_Tex_Coord4D)		return fn;
    if (fn==job_P_Gl_Tex_Coord4F)		return fn;
    if (fn==job_P_Gl_Tex_Coord4I)		return fn;
    if (fn==job_P_Gl_Tex_Coord4S)		return fn;
    if (fn==job_P_Gl_Tex_Coord1Dv)		return fn;
    if (fn==job_P_Gl_Tex_Coord1Fv)		return fn;
    if (fn==job_P_Gl_Tex_Coord1Iv)		return fn;
    if (fn==job_P_Gl_Tex_Coord1Sv)		return fn;
    if (fn==job_P_Gl_Tex_Coord2Dv)		return fn;
    if (fn==job_P_Gl_Tex_Coord2Fv)		return fn;
    if (fn==job_P_Gl_Tex_Coord2Iv)		return fn;
    if (fn==job_P_Gl_Tex_Coord2Sv)		return fn;
    if (fn==job_P_Gl_Tex_Coord3Dv)		return fn;
    if (fn==job_P_Gl_Tex_Coord3Fv)		return fn;
    if (fn==job_P_Gl_Tex_Coord3Iv)		return fn;
    if (fn==job_P_Gl_Tex_Coord3Sv)		return fn;
    if (fn==job_P_Gl_Tex_Coord4Dv)		return fn;
    if (fn==job_P_Gl_Tex_Coord4Fv)		return fn;
    if (fn==job_P_Gl_Tex_Coord4Iv)		return fn;
    if (fn==job_P_Gl_Tex_Coord4Sv)		return fn;
    if (fn==job_P_Gl_Raster_Pos2D)		return fn;
    if (fn==job_P_Gl_Raster_Pos2F)		return fn;
    if (fn==job_P_Gl_Raster_Pos2I)		return fn;
    if (fn==job_P_Gl_Raster_Pos2S)		return fn;
    if (fn==job_P_Gl_Raster_Pos3D)		return fn;
    if (fn==job_P_Gl_Raster_Pos3F)		return fn;
    if (fn==job_P_Gl_Raster_Pos3I)		return fn;
    if (fn==job_P_Gl_Raster_Pos3S)		return fn;
    if (fn==job_P_Gl_Raster_Pos4D)		return fn;
    if (fn==job_P_Gl_Raster_Pos4F)		return fn;
    if (fn==job_P_Gl_Raster_Pos4I)		return fn;
    if (fn==job_P_Gl_Raster_Pos4S)		return fn;
    if (fn==job_P_Gl_Raster_Pos2Dv)		return fn;
    if (fn==job_P_Gl_Raster_Pos2Fv)		return fn;
    if (fn==job_P_Gl_Raster_Pos2Iv)		return fn;
    if (fn==job_P_Gl_Raster_Pos2Sv)		return fn;
    if (fn==job_P_Gl_Raster_Pos3Dv)		return fn;
    if (fn==job_P_Gl_Raster_Pos3Fv)		return fn;
    if (fn==job_P_Gl_Raster_Pos3Iv)		return fn;
    if (fn==job_P_Gl_Raster_Pos3Sv)		return fn;
    if (fn==job_P_Gl_Raster_Pos4Dv)		return fn;
    if (fn==job_P_Gl_Raster_Pos4Fv)		return fn;
    if (fn==job_P_Gl_Raster_Pos4Iv)		return fn;
    if (fn==job_P_Gl_Raster_Pos4Sv)		return fn;
    if (fn==job_P_Gl_Rectd)			return fn;
    if (fn==job_P_Gl_Rectf)			return fn;
    if (fn==job_P_Gl_Recti)			return fn;
    if (fn==job_P_Gl_Rects)			return fn;
    if (fn==job_P_Gl_Rectdv)			return fn;
    if (fn==job_P_Gl_Rectfv)			return fn;
    if (fn==job_P_Gl_Rectiv)			return fn;
    if (fn==job_P_Gl_Rectsv)			return fn;
    if (fn==job_P_Gl_Materialf)			return fn;
    if (fn==job_P_Gl_Materiali)			return fn;
    if (fn==job_P_Gl_Materialfv)		return fn;
    if (fn==job_P_Gl_Materialiv)		return fn;
    if (fn==job_P_Gl_Get_Materialfv)		return fn;
    if (fn==job_P_Gl_Get_Materialiv)		return fn;
    if (fn==job_P_Gl_Color_Material)		return fn;
    if (fn==job_P_Gl_Tex_Gend)			return fn;
    if (fn==job_P_Gl_Tex_Genf)			return fn;
    if (fn==job_P_Gl_Tex_Geni)			return fn;
    if (fn==job_P_Gl_Tex_Gendv)			return fn;
    if (fn==job_P_Gl_Tex_Genfv)			return fn;
    if (fn==job_P_Gl_Tex_Geniv)			return fn;
    if (fn==job_P_Gl_Get_Tex_Gendv)		return fn;
    if (fn==job_P_Gl_Get_Tex_Genfv)		return fn;
    if (fn==job_P_Gl_Get_Tex_Geniv)		return fn;
    if (fn==job_P_Gl_Tex_Envf)			return fn;
    if (fn==job_P_Gl_Tex_Envi)			return fn;
    if (fn==job_P_Gl_Tex_Envfv)			return fn;
    if (fn==job_P_Gl_Tex_Enviv)			return fn;
    if (fn==job_P_Gl_Get_Tex_Envfv)		return fn;
    if (fn==job_P_Gl_Get_Tex_Enviv)		return fn;
    if (fn==job_P_Gl_Tex_Parameterf)		return fn;
    if (fn==job_P_Gl_Tex_Parameteri)		return fn;
    if (fn==job_P_Gl_Tex_Parameterfv)		return fn;
    if (fn==job_P_Gl_Tex_Parameteriv)		return fn;
    if (fn==job_P_Gl_Get_Tex_Parameterfv)	return fn;
    if (fn==job_P_Gl_Get_Tex_Parameteriv)	return fn;
    if (fn==job_P_Gl_Get_Tex_Level_Parameterfv)	return fn;
    if (fn==job_P_Gl_Get_Tex_Level_Parameteriv)	return fn;
    if (fn==job_P_Gl_Tex_Image1D)		return fn;
    if (fn==job_P_Gl_Tex_Image2D)		return fn;
    if (fn==job_P_Gl_Get_Tex_Image)		return fn;
    if (fn==job_P_Gl_Gen_Textures)		return fn;
    if (fn==job_P_Gl_Delete_Textures)		return fn;
    if (fn==job_P_Gl_Bind_Texture)		return fn;
    if (fn==job_P_Gl_Prioritize_Textures)	return fn;
    if (fn==job_P_Gl_Are_Textures_Resident)	return fn;
    if (fn==job_P_Gl_Is_Texture)		return fn;
    if (fn==job_P_Gl_Tex_Sub_Image1D)		return fn;
    if (fn==job_P_Gl_Tex_Sub_Image2D)		return fn;
    if (fn==job_P_Gl_Copy_Tex_Image1D)		return fn;
    if (fn==job_P_Gl_Copy_Tex_Image2D)		return fn;
    if (fn==job_P_Gl_Copy_Tex_Sub_Image1D)	return fn;
    if (fn==job_P_Gl_Copy_Tex_Sub_Image2D)	return fn;
    if (fn==job_P_Gl_Map1D)			return fn;
    if (fn==job_P_Gl_Map1F)			return fn;
    if (fn==job_P_Gl_Map2D)			return fn;
    if (fn==job_P_Gl_Map2F)			return fn;
    if (fn==job_P_Gl_Get_Mapdv)			return fn;
    if (fn==job_P_Gl_Get_Mapfv)			return fn;
    if (fn==job_P_Gl_Get_Mapiv)			return fn;
    if (fn==job_P_Gl_Eval_Coord1D)		return fn;
    if (fn==job_P_Gl_Eval_Coord1F)		return fn;
    if (fn==job_P_Gl_Eval_Coord1Dv)		return fn;
    if (fn==job_P_Gl_Eval_Coord1Fv)		return fn;
    if (fn==job_P_Gl_Eval_Coord2D)		return fn;
    if (fn==job_P_Gl_Eval_Coord2F)		return fn;
    if (fn==job_P_Gl_Eval_Coord2Dv)		return fn;
    if (fn==job_P_Gl_Eval_Coord2Fv)		return fn;
    if (fn==job_P_Gl_Map_Grid1D)		return fn;
    if (fn==job_P_Gl_Map_Grid1F)		return fn;
    if (fn==job_P_Gl_Map_Grid2D)		return fn;
    if (fn==job_P_Gl_Map_Grid2F)		return fn;
    if (fn==job_P_Gl_Eval_Point1)		return fn;
    if (fn==job_P_Gl_Eval_Point2)		return fn;
    if (fn==job_P_Gl_Eval_Mesh1)		return fn;
    if (fn==job_P_Gl_Eval_Mesh2)		return fn;
    /* Buggo, will probably need safeguards */
    /* against buggy/malicious avatar code  */
    /* abusing matrix push/pop:             */
    if (job_P_Gl_Push_Matrix)			return fn;
    if (job_P_Gl_Pop_Matrix)			return fn;
    if (job_P_Gl_Load_Identity)			return fn;
    if (job_P_Gl_Load_Matrixd)			return fn;
    if (job_P_Gl_Load_Matrixf)			return fn;
    if (job_P_Gl_Mult_Matrixd)			return fn;
    if (job_P_Gl_Mult_Matrixf)			return fn;
    if (job_P_Gl_Rotated)			return fn;
    if (job_P_Gl_Rotatef)			return fn;
    if (job_P_Gl_Scaled)			return fn;
    if (job_P_Gl_Scalef)			return fn;
    if (job_P_Gl_Translated)			return fn;
    if (job_P_Gl_Translatef)			return fn;

    return ogl_Need_Unrestricted_OpenGL;
}


/************************************************************************/
/* {{{  ogl_Initialize_Dispatch_Tables					*/
/************************************************************************/

void
ogl_Initialize_Dispatch_Tables(
    void
) {
    int  i;
    for (i = JOB_SLOW_TABLE_MAX;   i --> 0; ) {
	job_No_OpenGL_Table3[i] = ogl_Need_Avatar_OpenGL;
	job_No_OpenGL_Table4[i] = ogl_Need_Avatar_OpenGL;

	job_No_Window_Table3[i] = ogl_Open_Window_Fn_Filter( job_Slow_Table3[i] );
	job_No_Window_Table4[i] = ogl_Open_Window_Fn_Filter( job_Slow_Table4[i] );

	job_Avatar_OpenGL_Table3[i] = ogl_Avatar_Fn_Filter( job_Slow_Table3[i] );
	job_Avatar_OpenGL_Table4[i] = ogl_Avatar_Fn_Filter( job_Slow_Table4[i] );
    }
}

/* }}} */



/************************************************************************/
/* {{{  ogl_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
ogl_Startup(
    void
) {
    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    ogl_startup();
}

/* }}} */


/************************************************************************/
/* {{{  ogl_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
ogl_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;
}

/* }}} */


/************************************************************************/
/* {{{  ogl_Shutdown -- end-of-world stuff.				*/

/************************************************************************/

void
ogl_Shutdown(
    void
) {
    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;
}

/* }}} */

/************************************************************************/
/* {{{  ogl_Select_OpenGL_Access_Level -- end-of-world stuff.		*/
/************************************************************************/

void
ogl_Select_OpenGL_Access_Level(
    Vm_Int level
){
    switch (level) {

    case OGL_NO_OPENGL:	
	job_OpenGL_Table3 = job_Slow_Table3;
	job_OpenGL_Table4 = job_Slow_Table4;
	break;

    case OGL_AVATAR_OPENGL:
/* buggo, should probably enable this only if */
/* there is a current window defined.         */
	job_OpenGL_Table3 = job_Slow_Table3;
	job_OpenGL_Table4 = job_Slow_Table4;
	break;

    case OGL_UNRESTRICTED_OPENGL:
	job_OpenGL_Table3 = job_Slow_Table3;
	job_OpenGL_Table4 = job_Slow_Table4;
	break;

    default:
	MUQ_FATAL("Bad ogl_Select_OpenGL_Access_Level() arg");
    }
}

/************************************************************************/
/* {{{  STUBS FOR SERVERS WITHOUT OPENGL GRAPHICS SUPPORT 		*/
/************************************************************************/
#ifndef HAVE_OPENGL

int  ogl_Have_OpenGL_Support(void){ return FALSE; }
static void ogl_startup(void){}

/* }}} */

/************************************************************************/
/*     --- FUNCTIONS FOR SERVERS WITH OPENGL GRAPHICS SUPPORT ---	*/
/************************************************************************/
#else /* Server -does- have OpenGL support */

int  ogl_Have_OpenGL_Support(void){ return TRUE; }

/************************************************************************/
/* {{{  GLUT interface code header stuff				*/

/************************************************************************/

/* Hacked interface to GLUT is in a separate file: */
#include "oglg.t"

#include <stdio.h>
#include <stdlib.h>

#ifdef HAVE_GL_GLX_H
#include   <GL/glx.h>
#endif

#ifdef HAVE_GL_GL_H
#include   <GL/gl.h>
#endif

#ifdef HAVE_GL_GLU_H
#include   <GL/glu.h>
#endif

#ifdef HAVE_X11_KEYSYMH
#include   <X11/keysym.h>
#endif

#ifdef HAVE_X11_XLIB_H
#include   <X11/Xlib.h>
#endif

#ifdef HAVE_X11_XUTIL_H
#include   <X11/Xutil.h>
#endif

/* }}} */
/************************************************************************/
/* {{{  GLUT interface code event queue globals				*/
/************************************************************************/

#define OPENGL_EVENTS_MAX 256	/* Keep this a power of two! */
#define OPENGL_EVENTS_MASK (OPENGL_EVENTS_MAX-1)

static struct openGLevent {
    int window; /* Window generating event.                             */
    int opcode;	/* One of GT_KEY/GT_MOUSE/GT_RESHAP/GT_DISPLAY/GT_MOTION*/
    int state;  /* Key pressed for keyboard calls.			*/
    int button; /* For mouseclicks.					*/
    int mask;   /* Modifiers for keystrokes and mouseclicks.		*/
    int x,y;    /* Mouseclicks.						*/
} eventQ[ OPENGL_EVENTS_MAX ];
/* Queue is empty when cat==rat.   */
/* Otherwise:                      */
/* eventQcat is next event to read.*/
/* eventQrat is first free slot.   */
static int eventQcat = 0;
static int eventQrat = 0;

/* GL allows us to query the mouse position, but GLUT only  */
/* allows us to ask for notification when it changes, so in */
/* this driver we need to keep our own mouseloc state vars: */
static Vm_Int ogl_mouse_x = 0;
static Vm_Int ogl_mouse_y = 0;

/* }}} */
/************************************************************************/
/* {{{ ogl_PutEvent							*/
/************************************************************************/

static int suppress_event_entry = FALSE;

#define GT_KEY        (1)
#define GT_KEY_UP     (2)
#define GT_MOUSE      (3)
#define GT_DISPLAY    (4)
#define GT_RESHAPE    (5)
#define GT_MOTION     (6)
#define GT_PASSIVE    (7)
#define GT_SPECIAL    (8)
#define GT_SPECIAL_UP (9)
#define GT_ENTRY     (10)
#define GT_STATUS    (11)
#define GT_VISIBLE   (12)
#define GT_BUTTONS   (13)
#define GT_DIALS     (14)
#define GT_BALLXYZ   (15)
#define GT_BALLROT   (16)
#define GT_BALLKEY   (17)
#define GT_PADXY     (18)
#define GT_PADKEY    (19)

void
ogl_PutEvent(
    struct openGLevent* e
) {
    if (suppress_event_entry) return;
    /* Collapse multiple redraw events into one: */
    if (e->opcode == GT_DISPLAY) {
        if (eventQcat!=eventQrat) {  /* Queue not empty */
            int lastrat = (eventQrat + (OPENGL_EVENTS_MAX-1)) & OPENGL_EVENTS_MASK;
	    if (eventQ[lastrat].opcode  == GT_DISPLAY) {
	        /* Silently drop redundant DISPLAY: */
		return;
	    }
	}        
    }


    /* Store new event: */
    eventQ[eventQrat] = *e;

    /* Increment "next free slot" pointer circularly: */
    eventQrat         =  ((eventQrat +1) & OPENGL_EVENTS_MASK);

    /* If we just overwrote a valid event, remember that: */
    if (eventQcat==eventQrat) {
        eventQcat     =  ((eventQcat +1) & OPENGL_EVENTS_MASK);
    }
}
 
/* }}} */

/************************************************************************/
/* {{{ ogl_GetEvent							*/
/************************************************************************/

int
ogl_GetEvent(
    struct openGLevent* e
) {
    /* Fail if queue is empty: */
    if (eventQcat==eventQrat)   return FALSE;

    /* Return first event: */
    *e = eventQ[eventQcat];

    /* Remove returned event from queue: */
    eventQcat  =  ((eventQcat +1) & OPENGL_EVENTS_MASK);

    return TRUE;
}
 
/* }}} */

/************************************************************************/
/* {{{ mouse and keyboard callbacks					*/

/************************************************************************/
/* Here we want to set up callbacks for:
	 window->keyboard(asciichar,x,y) for vanilla keyboard chars;
	 window->special( key,x,y) for special keyboard chars;
	 window->passive(x,y) for passive mouse motion;
	 window->motion( x,y) for mouse drags;
	 window->mouse( button,GLUT_UP/GLUT_DOWN,x,y) for mouse clicks;
	 window->entry( GLUT_ENTERED/GLUT_LEFT ) for mouse entry/exit into window;
	 window->windowStatus(...) for window becoming in/visible.
	 window->reshape(...) for window changing shape.
See B6 p481ff in glutbook.
*/
/* Quick and dirty callbacks for GLUT input: */

static void
ogl_KeyboardFunc(
    unsigned char key,
    int           x,
    int           y
) {
    struct openGLevent e;
    e.opcode = GT_KEY;
    e.window = glutGetWindow();
    e.state  = key;
    e.button = 0;	/* Just to have it initialized. */
    e.x      = x;
    e.y      = y;
    e.mask   = __glutModifierMask;
    ogl_PutEvent( &e );

    ogl_mouse_x = x;
    ogl_mouse_y = y;
}

static void
ogl_KeyboardUpFunc(
    unsigned char key,
    int           x,
    int           y
) {
    struct openGLevent e;
    e.opcode = GT_KEY_UP;
    e.window = glutGetWindow();
    e.state  = key;
    e.button = 0;	/* Just to have it initialized. */
    e.x      = x;
    e.y      = y;
    e.mask   = __glutModifierMask;
    ogl_PutEvent( &e );

    ogl_mouse_x = x;
    ogl_mouse_y = y;
}

static void
ogl_MouseFunc(
    int button,
    int state,
    int x,
    int y
) {
    struct openGLevent e;
    e.opcode = GT_MOUSE;
    e.window = glutGetWindow();
    e.state  = state;
    e.button = button;
    e.x      = x;
    e.y      = y;
    e.mask   = __glutModifierMask;
    ogl_PutEvent( &e );

    ogl_mouse_x = x;
    ogl_mouse_y = y;
}

static void 
ogl_DisplayFunc(
    void
) {
    struct openGLevent e;
    e.opcode = GT_DISPLAY;
    e.window = glutGetWindow();
    e.state  = 0;	/* Just to have it initialized. */
    e.button = 0;	/* Just to have it initialized. */
    e.x      = 0;	/* Just to have it initialized. */
    e.y      = 0;	/* Just to have it initialized. */
    e.mask   = 0;	/* Just to have it initialized. */
    ogl_PutEvent( &e );
}

static void
ogl_ReshapeFunc(
    int wide,
    int high
) {
    /* Do the standard GLUT reshape processing: */
    __glutDefaultReshape( wide, high );

    /* Queue a redraw event. */
    {   struct openGLevent e;
        e.opcode = GT_RESHAPE;
        e.window = glutGetWindow();
        e.state  = 0;   /* Just to have it initialized. */
        e.button = 0;   /* Just to have it initialized. */
        e.x      = wide;
        e.y      = high;
        e.mask   = 0;	/* Just to have it initialized. */
        ogl_PutEvent( &e );
    }
}


static void 
ogl_MotionFunc(
    int x,
    int y
) {
    ogl_mouse_x = x;
    ogl_mouse_y = y;

    /* Queue a mouse drag event. */
    {   struct openGLevent e;
        e.opcode = GT_MOTION;
        e.window = glutGetWindow();
        e.state  = 0;	/* Just to have it initialized. */
        e.button = 0;	/* Just to have it initialized. */
        e.x      = x;
        e.y      = y;
        e.mask   = 0;	/* Just to have it initialized. */
        ogl_PutEvent( &e );
    }
}

static void 
ogl_PassiveFunc(
    int x,
    int y
) {
    ogl_mouse_x = x;
    ogl_mouse_y = y;

    /* Queue a mouse motion / no buttons event. */
    {   struct openGLevent e;
        e.opcode = GT_PASSIVE;
        e.window = glutGetWindow();
        e.state  = 0;	/* Just to have it initialized. */
        e.button = 0;	/* Just to have it initialized. */
        e.x      = x;
        e.y      = y;
        e.mask   = 0;	/* Just to have it initialized. */
        ogl_PutEvent( &e );
    }
}
static void 
ogl_MenuStatusFunc(
    int state,
    int x,
    int y
) {
    /* Queue a ? event. */
    {   struct openGLevent e;
        e.opcode = GT_STATUS;
        e.window = glutGetWindow();
        e.state  = state;
        e.button = 0;	/* Just to have it initialized. */
        e.x      = x;
        e.y      = y;
        e.mask   = 0;	/* Just to have it initialized. */
        ogl_PutEvent( &e );
    }
}

static void 
ogl_VisibilityFunc(
    int state
) {
    /* Queue a ? event. */
    {   struct openGLevent e;
        e.opcode = GT_VISIBLE;
        e.window = glutGetWindow();
        e.state  = state;
        e.button = 0;	/* Just to have it initialized. */
        e.x      = 0;	/* Just to have it initialized. */
        e.y      = 0;	/* Just to have it initialized. */
        e.mask   = 0;	/* Just to have it initialized. */
        ogl_PutEvent( &e );
    }
}

static void 
ogl_SpecialFunc(
    int key,
    int x,
    int y
) {
    /* Queue a function/cursor key press event. */
    {   struct openGLevent e;
        e.opcode = GT_SPECIAL;
        e.window = glutGetWindow();
        e.state  = 0;	/* Just to have it initialized. */
        e.button = key;
        e.x      = x;
        e.y      = y;
        e.mask   = 0;	/* Just to have it initialized. */
        ogl_PutEvent( &e );
    }
}

static void 
ogl_SpecialUpFunc(
    int key,
    int x,
    int y
) {
    /* Queue a function/cursor key release event. */
    {   struct openGLevent e;
        e.opcode = GT_SPECIAL_UP;
        e.window = glutGetWindow();
        e.state  = 0;	/* Just to have it initialized. */
        e.button = key;
        e.x      = x;
        e.y      = y;
        e.mask   = 0;	/* Just to have it initialized. */
        ogl_PutEvent( &e );
    }
}

static void 
ogl_EntryFunc(
    int state
) {
    /* Queue a cursor entering/leaving window event. */
    {   struct openGLevent e;
        e.opcode = GT_ENTRY;
        e.window = glutGetWindow();
        e.state  = state;
        e.button = 0;	/* Just to have it initialized. */
        e.x      = 0;	/* Just to have it initialized. */
        e.y      = 0;	/* Just to have it initialized. */
        e.mask   = 0;	/* Just to have it initialized. */
        ogl_PutEvent( &e );
    }
}

static void 
ogl_DialsFunc(
    int dial,
    int angle
) {
    /* Queue a motion event. */
    {   struct openGLevent e;
        e.opcode = GT_DIALS;
        e.window = glutGetWindow();
        e.state  = 0;	/* Just to have it initialized. */
        e.button = dial;
        e.x      = angle;
        e.y      = 0;	/* Just to have it initialized. */
        e.mask   = 0;	/* Just to have it initialized. */
        ogl_PutEvent( &e );
    }
}

static void 
ogl_ButtonBoxFunc(
    int button,
    int state
) {
    /* Queue a motion event. */
    {   struct openGLevent e;
        e.opcode = GT_BUTTONS;
        e.window = glutGetWindow();
        e.state  = state;
        e.button = button;
        e.x      = 0;	/* Just to have it initialized. */
        e.y      = 0;	/* Just to have it initialized. */
        e.mask   = 0;	/* Just to have it initialized. */
        ogl_PutEvent( &e );
    }
}

static void 
ogl_TabletMotionFunc(
    int x,
    int y
) {
    /* Queue a tablet motion event. */
    {   struct openGLevent e;
        e.opcode = GT_PADXY;
        e.window = glutGetWindow();
        e.state  = 0;	/* Just to have it initialized. */
        e.button = 0;	/* Just to have it initialized. */
        e.x      = x;
        e.y      = y;
        e.mask   = 0;	/* Just to have it initialized. */
        ogl_PutEvent( &e );
    }
}

static void 
ogl_TabletButtonFunc(
    int button,
    int state,
    int x,
    int y
) {
    /* Queue a tablet motion event. */
    {   struct openGLevent e;
        e.opcode = GT_PADKEY;
        e.window = glutGetWindow();
        e.state  = state;
        e.button = button;
        e.x      = x;
        e.y      = y;
        e.mask   = 0;	/* Just to have it initialized. */
        ogl_PutEvent( &e );
    }
}

static void 
ogl_SpaceballButtonFunc(
    int button,
    int state
) {
    /* Queue a tablet motion event. */
    {   struct openGLevent e;
        e.opcode = GT_BALLKEY;
        e.window = glutGetWindow();
        e.state  = state;
        e.button = button;
        e.x      = 0;	/* Just to have it initialized. */
        e.y      = 0;	/* Just to have it initialized. */
        e.mask   = 0;	/* Just to have it initialized. */
        ogl_PutEvent( &e );
    }
}

static void 
ogl_SpaceballMotionFunc(
    int x,
    int y,
    int z
) {
    /* Queue a tablet motion event. */
    {   struct openGLevent e;
        e.opcode = GT_BALLXYZ;
        e.window = glutGetWindow();
        e.state  = z;
        e.button = 0;	/* Just to have it initialized. */
        e.x      = x;
        e.y      = y;
        e.mask   = 0;	/* Just to have it initialized. */
        ogl_PutEvent( &e );
    }
}

static void 
ogl_SpaceballRotateFunc(
    int x,
    int y,
    int z
) {
    /* Queue a tablet motion event. */
    {   struct openGLevent e;
        e.opcode = GT_BALLROT;
        e.window = glutGetWindow();
        e.state  = z;
        e.button = 0;	/* Just to have it initialized. */
        e.x      = x;
        e.y      = y;
        e.mask   = 0;	/* Just to have it initialized. */
        ogl_PutEvent( &e );
    }
}

/* }}} */
/************************************************************************/
/* {{{ ogl_register_window_callbacks					*/
/************************************************************************/

static void
ogl_register_window_callbacks(
    void
) {
    /* Set up hooks to get keyboard and mouse input &tc: */
    glutPassiveMotionFunc(           ogl_PassiveFunc );
    glutDisplayFunc(                 ogl_DisplayFunc );
    glutKeyboardFunc(               ogl_KeyboardFunc );
    glutKeyboardUpFunc(           ogl_KeyboardUpFunc );
    glutReshapeFunc(                 ogl_ReshapeFunc );
    glutEntryFunc(                     ogl_EntryFunc );
    glutMouseFunc(                     ogl_MouseFunc );
    glutMotionFunc(                   ogl_MotionFunc );
    glutSpecialFunc(                 ogl_SpecialFunc );
    glutSpecialUpFunc(             ogl_SpecialUpFunc );
    glutVisibilityFunc(           ogl_VisibilityFunc );
    glutMenuStatusFunc(           ogl_MenuStatusFunc );
    glutDialsFunc(                     ogl_DialsFunc );
    glutButtonBoxFunc(             ogl_ButtonBoxFunc );
    glutTabletMotionFunc(       ogl_TabletMotionFunc );
    glutTabletButtonFunc(       ogl_TabletButtonFunc );
    glutSpaceballButtonFunc( ogl_SpaceballButtonFunc );
    glutSpaceballMotionFunc( ogl_SpaceballMotionFunc );
    glutSpaceballRotateFunc( ogl_SpaceballRotateFunc );
}

/* }}} */

/************************************************************************/
/* {{{ gluqProcessWindowWorkList					*/
/************************************************************************/
static void
gluqProcessWindowWorkList(
    void
) {
    if (__glutWindowWorkList) {
        GLUTwindow *work = __glutWindowWorkList;
        __glutWindowWorkList = NULL;
        if (work) {
            GLUTwindow *remainder = processWindowWorkList(work);
            if (remainder) {
                *beforeEnd = __glutWindowWorkList;
                __glutWindowWorkList = remainder;
            }
        }
    }
}

/* }}} */
/************************************************************************/
/* {{{ OPENGL_init -- 							*/
/************************************************************************/

/* Need to rehack this to use above code,    */
/* to at least a first approximation, then   */
/* go back and snarf the event processing    */
/* logic from zrgb and rehack our local code */
/* accordingly. */




/****************************************/
/* MESA support for offscreen rendering */
/****************************************/
/* Not currently doing offscreen rendering in Muq*/
#ifdef MAYBE_SOMEDAY
#ifdef HAVE_GL_OSMESA_H
#include <GL/osmesa.h>
static OSMesaContext osmesa_ctx;
static void *osmesa_buffer;
static int   osmesa_high;
static int   osmesa_wide;
#endif
#endif

static void
ogl_startup(
    void
){


    extern Vm_Int   main_ArgC;
    extern Vm_Uch** main_ArgV;

    /* glutinit() likes to eat commandline args: */
    {   int     argc =          main_ArgC;
        char**  argv = (char**) main_ArgV;
        glutInit( &argc, argv );
	main_ArgC    =           argc;
        main_ArgV    = (Vm_Uch**)argv;
    }
}

/* }}} */


/************************************************************************/
/* End of conditional deciding whether we have OpenGL support in server	*/
/************************************************************************/
#endif

/************************************************************************/
/* #include of jobg.t bytecode-primitive source code			*/
/************************************************************************/
#include "jobg.t"


/************************************************************************/
/* {{{ File variables							*/
/************************************************************************/
/*

Local variables:
mode: c
mode: outline-minor
outline-regexp: "\/\\* \\{\\{\\{[ \\t]*"
case-fold-search: nil
folded-file: t
fold-fold-on-startup: nil
End:
*/

/* }}} */

@end example
