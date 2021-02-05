/*--   jobg.c -- OpenGL bindings.					*/
/*- This file is formatted for outline-minor-mode in emacs19.		*/
/*-^C^O^A shows All of file.						*/
/* ^C^O^Q Quickfolds entire file. (Leaves only top-level headings.)	*/
/* ^C^O^T hides all Text. (Leaves all headings.)			*/
/* ^C^O^I shows Immediate children of node.				*/
/* ^C^O^S Shows all of a node.						*/
/* ^C^O^D hiDes all of a node.						*/
/* ^HFoutline-mode gives more details.					*/
/* (Or do ^HI and read emacs:outline mode.)				*/

/************************************************************************/
/*-    Dedication and Copyright.					*/
/************************************************************************/

/************************************************************************/
/*									*/
/*		For Firiss:  Aefrit, a friend.				*/
/*									*/
/************************************************************************/

/************************************************************************/
/* Author:       Jeff Prothero						*/
/* Created:      99Aug29.						*/
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

/************************************************************************/
/*-    COMPILATION NOTE.						*/
/************************************************************************/

/* This file is #included in ogl.t rather than being compiled directly	*/
/* by Makefile2:  This avoids duplication of #include logic.		*/

/************************************************************************/
/*-    Quote								*/
/************************************************************************/

/*
 "Beware of the above code; I have only proved it correct, not tried it."
                     -- Donald Knuth, note to colleague.
 */ 

/************************************************************************/
/*-    Scaling notes							*/
/************************************************************************/

/*
  99Oct16 Science News has an interview with
   Geoffrey B West of Los Alamos National Laboratory
                   and the Sante Fe Institute, and
   James H Brown of U New Mexico/Albuquerque and
   Brian J Enquist of UCSB.

     The main focus of the article is their exploration of why
   many biological scaling laws go as 1/4 powers when simple
   calculations would suggest 1/3 powers, deriving basically from
   space being three-dimensional.  Their basic conclusion is that
   organisms are space-filling fractals of dimension essentially 4,
   if I paraphrase correctly.

   They first published on this in spring of 1997.  (Where?)
   This SN article was apparently triggered by a 99Aug12 NATURE one.
   A 99May13 NATURE article is cited as claiming a more general result.

     As a trivial side observation that might be useful to me/us here,
   they note:

     Blood vessels BRANCH about 15 times from heart to capilary. (In dog.)

     RADIUS shrinks AT 0.58 proportion at branch points.
     LENGTH shrinks AT 0.69 proportion at branch points.

     They seem to be implying that just about all natural branching
     hierarchies will have similar statistics, although I don't see
     a flat statement or comparisons.

     I'd thought the outgoing cross-sectional area needs to match the
     incoming cross-sectional area, but 2*(0.58**2) is 0.667: Looks
     like they want outgoing cross section 2/3 of incoming.  So blood
     velocity must rise at each dividing point?  Odd.  If anything I'd
     have guessed you'd want it to drop to compensate for increased
     surface drag on flow.  Obviously I'm missing the key scaling
     consideration(s), whatever it is.  Maybe it is something like
     the smaller vessels, having a higher curvature, can support
     greater pressure?  All beyond me.  Increased flow velocity should
     mean lower pressure by the venturi principle?  Maybe the critical
     design goal is to minimize total evolume of capillaries needed,
     since they tend to fill all available space?  If so minimizing
     wall thickness needed by minimizing pressure by maximizing flow
     velocity might make some intuitive sense?  This is probably all
     totally off base :-]
   
 */ 

/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"
#include "jobprims.h"

/************************************************************************/
/*-    Stubs for servers without OpenGL support				*/
/************************************************************************/

#ifndef HAVE_OPENGL

static void
job_no_OpenGL(
    void
) {
    MUQ_WARN("OpenGL was not compiled into this server");
}
void job_P_Glut_Create_Window(    void) { job_no_OpenGL(); }
void job_P_Glut_Clear(            void) { job_no_OpenGL(); }
void job_P_Glut_Swap_Buffers(     void) { job_no_OpenGL(); }
void job_P_Glu_Perspective(       void) { job_no_OpenGL(); }
void job_P_Glu_Lookat(            void) { job_no_OpenGL(); }

void job_P_Glu_Ortho2D(			void) { job_no_OpenGL(); }
void job_P_Glu_Pick_Matrix(		void) { job_no_OpenGL(); }
void job_P_Glu_Project(			void) { job_no_OpenGL(); }
void job_P_Glu_Un_Project(		void) { job_no_OpenGL(); }
void job_P_Glu_Error_String(		void) { job_no_OpenGL(); }
void job_P_Glu_Scale_Image(		void) { job_no_OpenGL(); }
void job_P_Glu_Build1D_Mipmaps(		void) { job_no_OpenGL(); }
void job_P_Glu_Build2D_Mipmaps(		void) { job_no_OpenGL(); }
void job_P_Glu_New_Quadric(		void) { job_no_OpenGL(); }
void job_P_Glu_Delete_Quadric(		void) { job_no_OpenGL(); }
void job_P_Glu_Quadric_Draw_Style(	void) { job_no_OpenGL(); }
void job_P_Glu_Quadric_Orientation(	void) { job_no_OpenGL(); }
void job_P_Glu_Quadric_Normals(		void) { job_no_OpenGL(); }
void job_P_Glu_Quadric_Texture(		void) { job_no_OpenGL(); }
void job_P_Glu_Quadric_Callback(	void) { job_no_OpenGL(); }
void job_P_Glu_Cylinder(		void) { job_no_OpenGL(); }
void job_P_Glu_Sphere(			void) { job_no_OpenGL(); }
void job_P_Glu_Disk(			void) { job_no_OpenGL(); }
void job_P_Glu_Partial_Disk(		void) { job_no_OpenGL(); }
void job_P_Glu_New_Nurbs_Renderer(	void) { job_no_OpenGL(); }
void job_P_Glu_Delete_Nurbs_Renderer(	void) { job_no_OpenGL(); }
void job_P_Glu_Load_Sampling_Matrices(	void) { job_no_OpenGL(); }
void job_P_Glu_Nurbs_Property(		void) { job_no_OpenGL(); }
void job_P_Glu_Get_Nurbs_Property(	void) { job_no_OpenGL(); }
void job_P_Glu_Begin_Curve(		void) { job_no_OpenGL(); }
void job_P_Glu_End_Curve(		void) { job_no_OpenGL(); }
void job_P_Glu_Nurbs_Curve(		void) { job_no_OpenGL(); }
void job_P_Glu_Begin_Surface(		void) { job_no_OpenGL(); }
void job_P_Glu_End_Surface(		void) { job_no_OpenGL(); }
void job_P_Glu_Nurbs_Surface(		void) { job_no_OpenGL(); }
void job_P_Glu_Begin_Trim(		void) { job_no_OpenGL(); }
void job_P_Glu_End_Trim(		void) { job_no_OpenGL(); }
void job_P_Glu_Pwl_Curve(		void) { job_no_OpenGL(); }
void job_P_Glu_Nurbs_Callback(		void) { job_no_OpenGL(); }
void job_P_Glu_New_Tess(		void) { job_no_OpenGL(); }
void job_P_Glu_Tess_Callback(		void) { job_no_OpenGL(); }
void job_P_Glu_Delete_Tess(		void) { job_no_OpenGL(); }
void job_P_Glu_Begin_Polygon(		void) { job_no_OpenGL(); }
void job_P_Glu_End_Polygon(		void) { job_no_OpenGL(); }
void job_P_Glu_Next_Contour(		void) { job_no_OpenGL(); }
void job_P_Glu_Tess_Vertex(		void) { job_no_OpenGL(); }
void job_P_Glu_Get_String(		void) { job_no_OpenGL(); }

void job_P_Glut_Game_Mode_String( void) { job_no_OpenGL(); } 
void job_P_Glut_Post_Redisplay(   void) { job_no_OpenGL(); } 

void job_P_Glut_Init_Display_Mode(        void ) { job_no_OpenGL(); }
void job_P_Glut_Init_Display_String(      void ) { job_no_OpenGL(); }
void job_P_Glut_Init_Window_Position(     void ) { job_no_OpenGL(); }
void job_P_Glut_Init_Window_Size(         void ) { job_no_OpenGL(); }
void job_P_Glut_Create_Sub_Window(        void ) { job_no_OpenGL(); }
void job_P_Glut_Destroy_Window(           void ) { job_no_OpenGL(); }
void Job_P_Glut_Post_Redisplay(           void ) { job_no_OpenGL(); }
void job_P_Glut_Post_Window_Redisplay(    void ) { job_no_OpenGL(); }
void job_P_Glut_Get_Window(               void ) { job_no_OpenGL(); }
void job_P_Glut_Set_Window(               void ) { job_no_OpenGL(); }
void job_P_Glut_Set_Window_Title(         void ) { job_no_OpenGL(); }
void job_P_Glut_Set_Icon_Title(           void ) { job_no_OpenGL(); }
void job_P_Glut_Position_Window(          void ) { job_no_OpenGL(); }
void job_P_Glut_Reshape_Window(           void ) { job_no_OpenGL(); }
void job_P_Glut_Pop_Window(               void ) { job_no_OpenGL(); }
void job_P_Glut_Push_Window(              void ) { job_no_OpenGL(); }
void job_P_Glut_Iconify_Window(           void ) { job_no_OpenGL(); }
void job_P_Glut_Show_Window(              void ) { job_no_OpenGL(); }
void job_P_Glut_Hide_Window(              void ) { job_no_OpenGL(); }
void job_P_Glut_Full_Screen(              void ) { job_no_OpenGL(); }
void job_P_Glut_Set_Cursor(               void ) { job_no_OpenGL(); }
void job_P_Glut_Warp_Pointer(             void ) { job_no_OpenGL(); }
void job_P_Glut_Establish_Overlay(        void ) { job_no_OpenGL(); }
void job_P_Glut_Remove_Overlay(           void ) { job_no_OpenGL(); }
void job_P_Glut_Use_Layer(                void ) { job_no_OpenGL(); }
void job_P_Glut_Post_Overlay_Redisplay(   void ) { job_no_OpenGL(); }
void job_P_Glut_Window_Overlay_Redisplay( void ) { job_no_OpenGL(); }
void job_P_Glut_Show_Overlay(             void ) { job_no_OpenGL(); }
void job_P_Glut_Hide_Overlay(             void ) { job_no_OpenGL(); }
void job_P_Glut_Set_Color(                void ) { job_no_OpenGL(); }
void job_P_Glut_Get_Color(                void ) { job_no_OpenGL(); }
void job_P_Glut_Copy_Colormap(            void ) { job_no_OpenGL(); }
void job_P_Glut_Get(                      void ) { job_no_OpenGL(); }
void job_P_Glut_Device_Get(               void ) { job_no_OpenGL(); }
void job_P_Glut_Extension_Supported(      void ) { job_no_OpenGL(); }
void job_P_Glut_Get_Modifiers(            void ) { job_no_OpenGL(); }
void job_P_Glut_Layer_Get(                void ) { job_no_OpenGL(); }
void job_P_Glut_Bitmap_Character(         void ) { job_no_OpenGL(); }
void job_P_Glut_Bitmap_Width(             void ) { job_no_OpenGL(); }
void job_P_Glut_Stroke_Character(         void ) { job_no_OpenGL(); }
void job_P_Glut_Stroke_Width(             void ) { job_no_OpenGL(); }
void job_P_Glut_Bitmap_Length(            void ) { job_no_OpenGL(); }
void job_P_Glut_Stroke_Length(            void ) { job_no_OpenGL(); }
void job_P_Glut_Wire_Sphere(              void ) { job_no_OpenGL(); }
void job_P_Glut_Solid_Sphere(             void ) { job_no_OpenGL(); }
void job_P_Glut_Wire_Cone(                void ) { job_no_OpenGL(); }
void job_P_Glut_Solid_Cone(               void ) { job_no_OpenGL(); }
void job_P_Glut_Wire_Cube(                void ) { job_no_OpenGL(); }
void job_P_Glut_Solid_Cube(               void ) { job_no_OpenGL(); }
void job_P_Glut_Wire_Torus(               void ) { job_no_OpenGL(); }
void job_P_Glut_Solid_Torus(              void ) { job_no_OpenGL(); }
void job_P_Glut_Wire_Dodecahedron(        void ) { job_no_OpenGL(); }
void job_P_Glut_Solid_Dodecahedron(       void ) { job_no_OpenGL(); }
void job_P_Glut_Wire_Teapot(              void ) { job_no_OpenGL(); }
void job_P_Glut_Solid_Teapot(             void ) { job_no_OpenGL(); }
void job_P_Glut_Wire_Octahedron(          void ) { job_no_OpenGL(); }
void job_P_Glut_Solid_Octahedron(         void ) { job_no_OpenGL(); }
void job_P_Glut_Wire_Tetrahedron(         void ) { job_no_OpenGL(); }
void job_P_Glut_Solid_Tetrahedron(        void ) { job_no_OpenGL(); }
void job_P_Glut_Wire_Icosahedron(         void ) { job_no_OpenGL(); }
void job_P_Glut_Solid_Icosahedron(        void ) { job_no_OpenGL(); }
void job_P_Glut_Video_Resize_Get(         void ) { job_no_OpenGL(); }
void job_P_Glut_Setup_Video_Resizing(     void ) { job_no_OpenGL(); }
void job_P_Glut_Stop_Video_Resizing(      void ) { job_no_OpenGL(); }
void job_P_Glut_Video_Resize(             void ) { job_no_OpenGL(); }
void job_P_Glut_Video_Pan(                void ) { job_no_OpenGL(); }
void job_P_Glut_Report_Errors(            void ) { job_no_OpenGL(); }
void job_P_Glut_Ignore_Key_Repeat(        void ) { job_no_OpenGL(); }
void job_P_Glut_Set_Key_Repeat(           void ) { job_no_OpenGL(); }
void job_P_Glut_Enter_Game_Mode(          void ) { job_no_OpenGL(); }
void job_P_Glut_Leave_Game_Mode(          void ) { job_no_OpenGL(); }
void job_P_Glut_Game_Mode_Get(            void ) { job_no_OpenGL(); }

void job_P_Gluq_Events_Pending(           void) { job_no_OpenGL(); }
void job_P_Gluq_Event(                    void) { job_no_OpenGL(); }
void job_P_Gluq_Queue_Event(              void) { job_no_OpenGL(); }
void job_P_Gluq_Mouse_Position(           void) { job_no_OpenGL(); }

void job_P_Gluq_Draw_Quadruped(           void) { job_no_OpenGL(); }
void job_P_Gluq_Draw_Biped(               void) { job_no_OpenGL(); }
void job_P_Gluq_Draw_Face(                void) { job_no_OpenGL(); }
void job_P_Gluq_Draw_Terrain(             void) { job_no_OpenGL(); }

void job_P_Gl_Clear_Index(		void ) { job_no_OpenGL(); }
void job_P_Gl_Clear_Color(		void ) { job_no_OpenGL(); }
void job_P_Gl_Clear(		void ) { job_no_OpenGL(); }
void job_P_Gl_Index_Mask(		void ) { job_no_OpenGL(); }
void job_P_Gl_Color_Mask(		void ) { job_no_OpenGL(); }
void job_P_Gl_Alpha_Func(		void ) { job_no_OpenGL(); }
void job_P_Gl_Blend_Func(		void ) { job_no_OpenGL(); }
void job_P_Gl_Logic_Op(		void ) { job_no_OpenGL(); }
void job_P_Gl_Cull_Face(		void ) { job_no_OpenGL(); }
void job_P_Gl_Front_Face(		void ) { job_no_OpenGL(); }
void job_P_Gl_Point_Size(		void ) { job_no_OpenGL(); }
void job_P_Gl_Line_Width(		void ) { job_no_OpenGL(); }
void job_P_Gl_Line_Stipple(		void ) { job_no_OpenGL(); }
void job_P_Gl_Polygon_Mode(		void ) { job_no_OpenGL(); }
void job_P_Gl_Polygon_Offset(		void ) { job_no_OpenGL(); }
void job_P_Gl_Polygon_Stipple(		void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Polygon_Stipple(		void ) { job_no_OpenGL(); }
void job_P_Gl_Edge_Flag(		void ) { job_no_OpenGL(); }
void job_P_Gl_Edge_Flagv(		void ) { job_no_OpenGL(); }
void job_P_Gl_Scissor(		void ) { job_no_OpenGL(); }
void job_P_Gl_Clip_Plane(		void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Clip_Plane(		void ) { job_no_OpenGL(); }
void job_P_Gl_Draw_Buffer(		void ) { job_no_OpenGL(); }
void job_P_Gl_Read_Buffer(		void ) { job_no_OpenGL(); }
void job_P_Gl_Enable(		void ) { job_no_OpenGL(); }
void job_P_Gl_Disable(		void ) { job_no_OpenGL(); }
void job_P_Gl_Is_Enabled(		void ) { job_no_OpenGL(); }
void job_P_Gl_Enable_Client_State(		void ) { job_no_OpenGL(); }
void job_P_Gl_Disable_Client_State(		void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Boolean(		void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Double(		void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Float(		void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Integer(		void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Boolean_Block(	void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Double_Block(		void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Float_Block(		void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Integer_Block(	void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Booleanv(		void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Doublev(		void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Floatv(		void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Integerv(		void ) { job_no_OpenGL(); }
void job_P_Gl_Push_Attrib(		void ) { job_no_OpenGL(); }
void job_P_Gl_Pop_Attrib(		void ) { job_no_OpenGL(); }
void job_P_Gl_Push_Client_Attrib(		void ) { job_no_OpenGL(); }
void job_P_Gl_Pop_Client_Attrib(		void ) { job_no_OpenGL(); }
void job_P_Gl_Render_Mode(		void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Error(		void ) { job_no_OpenGL(); }
void job_P_Gl_Get_String(		void ) { job_no_OpenGL(); }
void job_P_Gl_Finish(		void ) { job_no_OpenGL(); }
void job_P_Gl_Flush(		void ) { job_no_OpenGL(); }
void job_P_Gl_Hint(		void ) { job_no_OpenGL(); }
void job_P_Gl_Clear_Depth(		void ) { job_no_OpenGL(); }
void job_P_Gl_Depth_Func(		void ) { job_no_OpenGL(); }
void job_P_Gl_Depth_Mask(		void ) { job_no_OpenGL(); }
void job_P_Gl_Depth_Range(		void ) { job_no_OpenGL(); }
void job_P_Gl_Clear_Accum(		void ) { job_no_OpenGL(); }
void job_P_Gl_Accum(		void ) { job_no_OpenGL(); }
void job_P_Gl_Matrix_Mode(		void ) { job_no_OpenGL(); }
void job_P_Gl_Ortho(		void ) { job_no_OpenGL(); }
void job_P_Gl_Frustum(		void ) { job_no_OpenGL(); }
void job_P_Gl_Viewport(		void ) { job_no_OpenGL(); }
void job_P_Gl_Push_Matrix(		void ) { job_no_OpenGL(); }
void job_P_Gl_Pop_Matrix(		void ) { job_no_OpenGL(); }
void job_P_Gl_Load_Identity(		void ) { job_no_OpenGL(); }
void job_P_Gl_Load_Matrixd(		void ) { job_no_OpenGL(); }
void job_P_Gl_Load_Matrixf(		void ) { job_no_OpenGL(); }
void job_P_Gl_Mult_Matrixd(		void ) { job_no_OpenGL(); }
void job_P_Gl_Mult_Matrixf(		void ) { job_no_OpenGL(); }
void job_P_Gl_Rotated(		void ) { job_no_OpenGL(); }
void job_P_Gl_Rotatef(		void ) { job_no_OpenGL(); }
void job_P_Gl_Scaled(		void ) { job_no_OpenGL(); }
void job_P_Gl_Scalef(		void ) { job_no_OpenGL(); }
void job_P_Gl_Translated(		void ) { job_no_OpenGL(); }
void job_P_Gl_Translatef(		void ) { job_no_OpenGL(); }
void job_P_Gl_Is_List(		void ) { job_no_OpenGL(); }
void job_P_Gl_Delete_Lists(		void ) { job_no_OpenGL(); }
void job_P_Gl_Gen_Lists(		void ) { job_no_OpenGL(); }
void job_P_Gl_New_List(		void ) { job_no_OpenGL(); }
void job_P_Gl_End_List(		void ) { job_no_OpenGL(); }
void job_P_Gl_Call_List(		void ) { job_no_OpenGL(); }
void job_P_Gl_Call_Lists(		void ) { job_no_OpenGL(); }
void job_P_Gl_List_Base(		void ) { job_no_OpenGL(); }
void job_P_Gl_Begin(		void ) { job_no_OpenGL(); }
void job_P_Gl_End(		void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex2D(		void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex2F(		void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex2I(		void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex2S(		void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex3D(		void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex3F(		void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex3I(		void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex3S(		void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex4D( void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex4F( void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex4I( void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex4S( void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex2Dv( void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex2Fv( void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex2Iv( void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex2Sv( void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex3Dv( void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex3Fv( void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex3Iv( void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex3Sv( void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex4Dv( void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex4Fv( void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex4Iv( void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex4Sv( void ) { job_no_OpenGL(); }
void job_P_Gl_Normal3B( void ) { job_no_OpenGL(); }
void job_P_Gl_Normal3D( void ) { job_no_OpenGL(); }
void job_P_Gl_Normal3F( void ) { job_no_OpenGL(); }
void job_P_Gl_Normal3I( void ) { job_no_OpenGL(); }
void job_P_Gl_Normal3S( void ) { job_no_OpenGL(); }
void job_P_Gl_Normal3Bv( void ) { job_no_OpenGL(); }
void job_P_Gl_Normal3Dv( void ) { job_no_OpenGL(); }
void job_P_Gl_Normal3Fv( void ) { job_no_OpenGL(); }
void job_P_Gl_Normal3Iv( void ) { job_no_OpenGL(); }
void job_P_Gl_Normal3Sv( void ) { job_no_OpenGL(); }
void job_P_Gl_Indexd( void ) { job_no_OpenGL(); }
void job_P_Gl_Indexf( void ) { job_no_OpenGL(); }
void job_P_Gl_Indexi( void ) { job_no_OpenGL(); }
void job_P_Gl_Indexs( void ) { job_no_OpenGL(); }
void job_P_Gl_Indexub( void ) { job_no_OpenGL(); }
void job_P_Gl_Indexdv( void ) { job_no_OpenGL(); }
void job_P_Gl_Indexfv( void ) { job_no_OpenGL(); }
void job_P_Gl_Indexiv( void ) { job_no_OpenGL(); }
void job_P_Gl_Indexsv( void ) { job_no_OpenGL(); }
void job_P_Gl_Indexubv( void ) { job_no_OpenGL(); }
void job_P_Gl_Color3B( void ) { job_no_OpenGL(); }
void job_P_Gl_Color3D( void ) { job_no_OpenGL(); }
void job_P_Gl_Color3F( void ) { job_no_OpenGL(); }
void job_P_Gl_Color3I( void ) { job_no_OpenGL(); }
void job_P_Gl_Color3S( void ) { job_no_OpenGL(); }
void job_P_Gl_Color3Ub( void ) { job_no_OpenGL(); }
void job_P_Gl_Color3Ui( void ) { job_no_OpenGL(); }
void job_P_Gl_Color3Us( void ) { job_no_OpenGL(); }
void job_P_Gl_Color4B( void ) { job_no_OpenGL(); }
void job_P_Gl_Color4D( void ) { job_no_OpenGL(); }
void job_P_Gl_Color4F( void ) { job_no_OpenGL(); }
void job_P_Gl_Color4I( void ) { job_no_OpenGL(); }
void job_P_Gl_Color4S( void ) { job_no_OpenGL(); }
void job_P_Gl_Color4Ub( void ) { job_no_OpenGL(); }
void job_P_Gl_Color4Ui( void ) { job_no_OpenGL(); }
void job_P_Gl_Color4Us( void ) { job_no_OpenGL(); }
void job_P_Gl_Color3Bv( void ) { job_no_OpenGL(); }
void job_P_Gl_Color3Dv( void ) { job_no_OpenGL(); }
void job_P_Gl_Color3Fv( void ) { job_no_OpenGL(); }
void job_P_Gl_Color3Iv( void ) { job_no_OpenGL(); }
void job_P_Gl_Color3Sv( void ) { job_no_OpenGL(); }
void job_P_Gl_Color3Ubv( void ) { job_no_OpenGL(); }
void job_P_Gl_Color3Uiv( void ) { job_no_OpenGL(); }
void job_P_Gl_Color3Usv( void ) { job_no_OpenGL(); }
void job_P_Gl_Color4Bv( void ) { job_no_OpenGL(); }
void job_P_Gl_Color4Dv( void ) { job_no_OpenGL(); }
void job_P_Gl_Color4Fv( void ) { job_no_OpenGL(); }
void job_P_Gl_Color4Iv( void ) { job_no_OpenGL(); }
void job_P_Gl_Color4Sv( void ) { job_no_OpenGL(); }
void job_P_Gl_Color4Ubv( void ) { job_no_OpenGL(); }
void job_P_Gl_Color4Uiv( void ) { job_no_OpenGL(); }
void job_P_Gl_Color4Usv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord1D( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord1F( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord1I( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord1S( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord2D( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord2F( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord2I( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord2S( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord3D( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord3F( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord3I( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord3S( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord4D( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord4F( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord4I( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord4S( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord1Dv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord1Fv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord1Iv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord1Sv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord2Dv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord2Fv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord2Iv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord2Sv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord3Dv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord3Fv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord3Iv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord3Sv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord4Dv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord4Fv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord4Iv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord4Sv( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos2D( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos2F( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos2I( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos2S( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos3D( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos3F( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos3I( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos3S( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos4D( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos4F( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos4I( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos4S( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos2Dv( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos2Fv( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos2Iv( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos2Sv( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos3Dv( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos3Fv( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos3Iv( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos3Sv( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos4Dv( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos4Fv( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos4Iv( void ) { job_no_OpenGL(); }
void job_P_Gl_Raster_Pos4Sv( void ) { job_no_OpenGL(); }
void job_P_Gl_Rectd( void ) { job_no_OpenGL(); }
void job_P_Gl_Rectf( void ) { job_no_OpenGL(); }
void job_P_Gl_Recti( void ) { job_no_OpenGL(); }
void job_P_Gl_Rects( void ) { job_no_OpenGL(); }
void job_P_Gl_Rectdv( void ) { job_no_OpenGL(); }
void job_P_Gl_Rectfv( void ) { job_no_OpenGL(); }
void job_P_Gl_Rectiv( void ) { job_no_OpenGL(); }
void job_P_Gl_Rectsv( void ) { job_no_OpenGL(); }
void job_P_Gl_Vertex_Pointer( void ) { job_no_OpenGL(); }
void job_P_Gl_Normal_Pointer( void ) { job_no_OpenGL(); }
void job_P_Gl_Color_Pointer( void ) { job_no_OpenGL(); }
void job_P_Gl_Index_Pointer( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Coord_Pointer( void ) { job_no_OpenGL(); }
void job_P_Gl_Edge_Flag_Pointer( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Pointerv( void ) { job_no_OpenGL(); }
void job_P_Gl_Array_Element( void ) { job_no_OpenGL(); }
void job_P_Gl_Draw_Arrays( void ) { job_no_OpenGL(); }
void job_P_Gl_Draw_Elements( void ) { job_no_OpenGL(); }
void job_P_Gl_Interleaved_Arrays( void ) { job_no_OpenGL(); }
void job_P_Gl_Shade_Model( void ) { job_no_OpenGL(); }
void job_P_Gl_Lightf( void ) { job_no_OpenGL(); }
void job_P_Gl_Lighti( void ) { job_no_OpenGL(); }
void job_P_Gl_Lightfv( void ) { job_no_OpenGL(); }
void job_P_Gl_Lightiv( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Lightfv( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Lightiv( void ) { job_no_OpenGL(); }
void job_P_Gl_Light_Modelf( void ) { job_no_OpenGL(); }
void job_P_Gl_Light_Modeli( void ) { job_no_OpenGL(); }
void job_P_Gl_Light_Modelfv( void ) { job_no_OpenGL(); }
void job_P_Gl_Light_Modeliv( void ) { job_no_OpenGL(); }
void job_P_Gl_Materialf( void ) { job_no_OpenGL(); }
void job_P_Gl_Materiali( void ) { job_no_OpenGL(); }
void job_P_Gl_Materialfv( void ) { job_no_OpenGL(); }
void job_P_Gl_Materialiv( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Materialfv( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Materialiv( void ) { job_no_OpenGL(); }
void job_P_Gl_Color_Material( void ) { job_no_OpenGL(); }
void job_P_Gl_Pixel_Zoom( void ) { job_no_OpenGL(); }
void job_P_Gl_Pixel_Storef( void ) { job_no_OpenGL(); }
void job_P_Gl_Pixel_Storei( void ) { job_no_OpenGL(); }
void job_P_Gl_Pixel_Transferf( void ) { job_no_OpenGL(); }
void job_P_Gl_Pixel_Transferi( void ) { job_no_OpenGL(); }
void job_P_Gl_Pixel_Mapfv( void ) { job_no_OpenGL(); }
void job_P_Gl_Pixel_Mapuiv( void ) { job_no_OpenGL(); }
void job_P_Gl_Pixel_Mapusv( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Pixel_Mapfv( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Pixel_Mapuiv( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Pixel_Mapusv( void ) { job_no_OpenGL(); }
void job_P_Gl_Bitmap( void ) { job_no_OpenGL(); }
void job_P_Gl_Read_Pixels( void ) { job_no_OpenGL(); }
void job_P_Gl_Draw_Pixels( void ) { job_no_OpenGL(); }
void job_P_Gl_Copy_Pixels( void ) { job_no_OpenGL(); }
void job_P_Gl_Stencil_Func( void ) { job_no_OpenGL(); }
void job_P_Gl_Stencil_Mask( void ) { job_no_OpenGL(); }
void job_P_Gl_Stencil_Op( void ) { job_no_OpenGL(); }
void job_P_Gl_Clear_Stencil( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Gend( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Genf( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Geni( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Gendv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Genfv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Geniv( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Tex_Gendv( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Tex_Genfv( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Tex_Geniv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Envf( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Envi( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Envfv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Enviv( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Tex_Envfv( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Tex_Enviv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Parameterf( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Parameteri( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Parameterfv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Parameteriv( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Tex_Parameterfv( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Tex_Parameteriv( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Tex_Level_Parameterfv( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Tex_Level_Parameteriv( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Image1D( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Image2D( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Tex_Image( void ) { job_no_OpenGL(); }
void job_P_Gl_Gen_Textures( void ) { job_no_OpenGL(); }
void job_P_Gl_Delete_Textures( void ) { job_no_OpenGL(); }
void job_P_Gl_Bind_Texture( void ) { job_no_OpenGL(); }
void job_P_Gl_Prioritize_Textures( void ) { job_no_OpenGL(); }
void job_P_Gl_Are_Textures_Resident( void ) { job_no_OpenGL(); }
void job_P_Gl_Is_Texture( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Sub_Image1D( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Sub_Image2D( void ) { job_no_OpenGL(); }
void job_P_Gl_Copy_Tex_Image1D( void ) { job_no_OpenGL(); }
void job_P_Gl_Copy_Tex_Image2D( void ) { job_no_OpenGL(); }
void job_P_Gl_Copy_Tex_Sub_Image1D( void ) { job_no_OpenGL(); }
void job_P_Gl_Copy_Tex_Sub_Image2D( void ) { job_no_OpenGL(); }
void job_P_Gl_Map1D( void ) { job_no_OpenGL(); }
void job_P_Gl_Map1F( void ) { job_no_OpenGL(); }
void job_P_Gl_Map2D( void ) { job_no_OpenGL(); }
void job_P_Gl_Map2F( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Mapdv( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Mapfv( void ) { job_no_OpenGL(); }
void job_P_Gl_Get_Mapiv( void ) { job_no_OpenGL(); }
void job_P_Gl_Eval_Coord1D( void ) { job_no_OpenGL(); }
void job_P_Gl_Eval_Coord1F( void ) { job_no_OpenGL(); }
void job_P_Gl_Eval_Coord1Dv( void ) { job_no_OpenGL(); }
void job_P_Gl_Eval_Coord1Fv( void ) { job_no_OpenGL(); }
void job_P_Gl_Eval_Coord2D( void ) { job_no_OpenGL(); }
void job_P_Gl_Eval_Coord2F( void ) { job_no_OpenGL(); }
void job_P_Gl_Eval_Coord2Dv( void ) { job_no_OpenGL(); }
void job_P_Gl_Eval_Coord2Fv( void ) { job_no_OpenGL(); }
void job_P_Gl_Map_Grid1D( void ) { job_no_OpenGL(); }
void job_P_Gl_Map_Grid1F( void ) { job_no_OpenGL(); }
void job_P_Gl_Map_Grid2D( void ) { job_no_OpenGL(); }
void job_P_Gl_Map_Grid2F( void ) { job_no_OpenGL(); }
void job_P_Gl_Eval_Point1( void ) { job_no_OpenGL(); }
void job_P_Gl_Eval_Point2( void ) { job_no_OpenGL(); }
void job_P_Gl_Eval_Mesh1( void ) { job_no_OpenGL(); }
void job_P_Gl_Eval_Mesh2( void ) { job_no_OpenGL(); }
void job_P_Gl_Fogf( void ) { job_no_OpenGL(); }
void job_P_Gl_Fogi( void ) { job_no_OpenGL(); }
void job_P_Gl_Fogfv( void ) { job_no_OpenGL(); }
void job_P_Gl_Fogiv( void ) { job_no_OpenGL(); }
void job_P_Gl_Feedback_Buffer( void ) { job_no_OpenGL(); }
void job_P_Gl_Pass_Through( void ) { job_no_OpenGL(); }
void job_P_Gl_Select_Buffer( void ) { job_no_OpenGL(); }
void job_P_Gl_Init_Names( void ) { job_no_OpenGL(); }
void job_P_Gl_Load_Name( void ) { job_no_OpenGL(); }
void job_P_Gl_Push_Name( void ) { job_no_OpenGL(); }
void job_P_Gl_Pop_Name( void ) { job_no_OpenGL(); }
void job_P_Gl_Draw_Range_Elements( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Image3D( void ) { job_no_OpenGL(); }
void job_P_Gl_Tex_Sub_Image3D( void ) { job_no_OpenGL(); }
void job_P_Gl_Copy_Tex_Sub_Image3D( void ) { job_no_OpenGL(); }

void job_P_Gla_Enable(  void ) { job_no_OpenGL(); }
void job_P_Gla_Disable( void ) { job_no_OpenGL(); }

#else

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

#ifdef HAVE_GL_OSMESA_H
#include <GL/osmesa.h>
#endif

/************************************************************************/
/*-    job_P_Glut_Swap_Buffers --					*/
/************************************************************************/

void
job_P_Glut_Swap_Buffers(
    void
) {
    glutSwapBuffers();
    glFlush();
}

/************************************************************************/
/*-    job_P_Glu_Perspective --						*/
/************************************************************************/

void
job_P_Glu_Perspective(
    void
) {
    job_Guarantee_N_Args( 4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   double fovy   = OBJ_TO_FLOAT( jS.s[-3] );
	double aspect = OBJ_TO_FLOAT( jS.s[-2] );
	double zNear  = OBJ_TO_FLOAT( jS.s[-1] );
	double zFar   = OBJ_TO_FLOAT( jS.s[ 0] );
        gluPerspective( fovy, aspect, zNear, zFar );
    }
    jS.s -= 4;
}

/************************************************************************/
/*-    job_P_Glu_Lookat --						*/
/************************************************************************/

void
job_P_Glu_Lookat(
    void
) {
    job_Guarantee_N_Args(     9 );
    job_Guarantee_Float_Arg( -8 );
    job_Guarantee_Float_Arg( -7 );
    job_Guarantee_Float_Arg( -6 );
    job_Guarantee_Float_Arg( -5 );
    job_Guarantee_Float_Arg( -4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   double eyex    = OBJ_TO_FLOAT( jS.s[-8] );
	double eyey    = OBJ_TO_FLOAT( jS.s[-7] );
	double eyez    = OBJ_TO_FLOAT( jS.s[-6] );
	double centerx = OBJ_TO_FLOAT( jS.s[-5] );
	double centery = OBJ_TO_FLOAT( jS.s[-4] );
	double centerz = OBJ_TO_FLOAT( jS.s[-3] );
	double upx     = OBJ_TO_FLOAT( jS.s[-2] );
	double upy     = OBJ_TO_FLOAT( jS.s[-1] );
	double upz     = OBJ_TO_FLOAT( jS.s[ 0] );

        gluLookAt(
	    eyex,    eyey,    eyez,
            centerx, centery, centerz,
            upx,     upy,     upz
	);
    }
    jS.s -= 9;
}

/************************************************************************/
/*-    job_P_Glu_Ortho2D --						*/
/************************************************************************/
void
job_P_Glu_Ortho2D(
    void
) {
    job_Guarantee_N_Args( 4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble left   = OBJ_TO_FLOAT( jS.s[-3] );
	GLdouble right  = OBJ_TO_FLOAT( jS.s[-2] );
	GLdouble bottom = OBJ_TO_FLOAT( jS.s[-1] );
	GLdouble top    = OBJ_TO_FLOAT( jS.s[ 0] );
        gluOrtho2D( left, right, bottom, top );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Glu_Pick_Matrix --						*/
/************************************************************************/
void
job_P_Glu_Pick_Matrix(
    void
) {
    job_Guarantee_N_Args(     5 );
    job_Guarantee_Float_Arg( -4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_I32_Len(    0, 4 );
    {   GLdouble x      = OBJ_TO_FLOAT( jS.s[-4] );
	GLdouble y      = OBJ_TO_FLOAT( jS.s[-3] );
	GLdouble delx   = OBJ_TO_FLOAT( jS.s[-2] );
	GLdouble dely   = OBJ_TO_FLOAT( jS.s[-1] );
        gluPickMatrix( x, y, delx, dely, &I32_P(jS.s[0])->slot[0] );
    }
    jS.s -= 5;
}
/************************************************************************/
/*-    job_P_Glu_Project --						*/
/************************************************************************/
void
job_P_Glu_Project(
    void
) {
    job_Guarantee_N_Args(     6 );
    job_Guarantee_Float_Arg( -5 );
    job_Guarantee_Float_Arg( -4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_F64_Len(   -2, 16 );
    job_Guarantee_F64_Len(   -1, 16 );
    job_Guarantee_I32_Len(    0, 4 );
    {   GLdouble x_out  = 0.0;
	GLdouble y_out  = 0.0;   
	GLdouble z_out  = 0.0;
        GLint    b_out;
        GLdouble x_in   = OBJ_TO_FLOAT( jS.s[-5] );
	GLdouble y_in   = OBJ_TO_FLOAT( jS.s[-4] );
	GLdouble z_in   = OBJ_TO_FLOAT( jS.s[-3] );
        F64_P    model  = NULL;	/* Just to quiet compilers. */
	F64_P    proj   = NULL;	/* Just to quiet compilers. */
	I32_P    view   = NULL;	/* Just to quiet compilers. */
	vm_Loc3(
	    (void**)&model,
	    (void**)&proj,
	    (void**)&view,
	    jS.s[-2],
	    jS.s[-1],
	    jS.s[ 0]
        );
	b_out = gluProject(
	    x_in,   y_in,   z_in,
	    &model->slot[0], &proj->slot[0], &view->slot[0],
	    &x_out, &y_out, &z_out
	);
	jS.s[-5] = OBJ_FROM_INT(b_out);
	jS.s[-4] = OBJ_FROM_FLOAT(x_out);
	jS.s[-3] = OBJ_FROM_FLOAT(y_out);
	jS.s[-2] = OBJ_FROM_FLOAT(z_out);
	jS.s    -= 2;
    }	       
}
/************************************************************************/
/*-    job_P_Glu_Un_Project --						*/
/************************************************************************/
void
job_P_Glu_Un_Project(
    void
) {
    job_Guarantee_N_Args(     6 );
    job_Guarantee_Float_Arg( -5 );
    job_Guarantee_Float_Arg( -4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_F64_Len(   -2, 16 );
    job_Guarantee_F64_Len(   -1, 16 );
    job_Guarantee_I32_Len(    0, 4 );
    {   GLdouble x_out  = 0.0;
	GLdouble y_out  = 0.0;   
	GLdouble z_out  = 0.0;
        GLint    b_out;
        GLdouble x_in   = OBJ_TO_FLOAT( jS.s[-5] );
	GLdouble y_in   = OBJ_TO_FLOAT( jS.s[-4] );
	GLdouble z_in   = OBJ_TO_FLOAT( jS.s[-3] );
        F64_P    model  = NULL;	/* Just to quiet compilers. */
	F64_P    proj   = NULL;	/* Just to quiet compilers. */
	I32_P    view   = NULL;	/* Just to quiet compilers. */
	vm_Loc3(
	    (void**)&model,
	    (void**)&proj,
	    (void**)&view,
	    jS.s[-2],
	    jS.s[-1],
	    jS.s[ 0]
        );
	b_out = gluUnProject(
	    x_in,   y_in,   z_in,
	    &model->slot[0], &proj->slot[0], &view->slot[0],
	    &x_out, &y_out, &z_out
	);
	jS.s[-5] = OBJ_FROM_INT(b_out);
	jS.s[-4] = OBJ_FROM_FLOAT(x_out);
	jS.s[-3] = OBJ_FROM_FLOAT(y_out);
	jS.s[-2] = OBJ_FROM_FLOAT(z_out);
	jS.s    -= 2;
    }	       
}
/************************************************************************/
/*-    job_P_Glu_Error_String --					*/
/************************************************************************/
void
job_P_Glu_Error_String(
    void
) {
    GLenum err = OBJ_TO_INT( *jS.s );
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    *jS.s = stg_From_Asciz( (Vm_Uch*)gluErrorString( err ) );
}
/************************************************************************/
/*-    job_P_Glu_Scale_Image --						*/
/************************************************************************/
void
job_P_Glu_Scale_Image(
    void
) {

    MUQ_WARN("job_P_Glu_Scale_Image unimplemented");
}
/************************************************************************/
/*-    job_P_Glu_Build1D_Mipmaps --					*/
/************************************************************************/
void
job_P_Glu_Build1D_Mipmaps(
    void
) {
    MUQ_WARN("job_P_Glu_Build1D_Mipmaps unimplemented");
}
/************************************************************************/
/*-    job_P_Glu_Build2D_Mipmaps --					*/
/************************************************************************/
void
job_P_Glu_Build2D_Mipmaps(
    void
) {
    MUQ_WARN("job_P_Glu_Build2D_Mipmaps unimplemented");
}

/************************************************************************/
/*-    job_Guarantee_Wdw_Arg --						*/
/************************************************************************/

Vm_Int
job_Guarantee_Wdw_Arg(
    Vm_Int n
) {
    Vm_Obj v = jS.s[n];
    if (OBJ_IS_INT(v))  return OBJ_TO_INT(v);
    if (!OBJ_IS_OBJ(v) || !OBJ_IS_CLASS_WDW(v)) {
        MUQ_WARN ("Needed glut window argument at top-of-stack[%d]", (int)n );
    }
    return OBJ_TO_INT( WDW_P(v)->id );
}

/************************************************************************/
/*-    quadric cache --							*/
/************************************************************************/

#define JOB_QUADRIC_MAX 16	/* Must be a power of two */
#define JOB_QUADRIC_MASK (JOB_QUADRIC_MAX-1)
static GLUquadricObj* quadric[JOB_QUADRIC_MAX];
static unsigned int quadric_clock = 0;

/************************************************************************/
/*-    job_get_glu_quadric --						*/
/************************************************************************/
static GLUquadricObj*
job_get_glu_quadric(
    int n
) {
    Vm_Int i = OBJ_TO_INT( jS.s[n] );
    job_Guarantee_Int_Arg( n );
    if (i & ~JOB_QUADRIC_MASK
    || !quadric[i]
    ){
        MUQ_WARN ("Needed glu quadric argument at top-of-stack[%d]", (int)n );
    }
    return quadric[i];
}

/************************************************************************/
/*-    job_get_enum --							*/
/************************************************************************/
static GLenum
job_get_enum(
    int i
) {
    GLenum j = OBJ_TO_INT( jS.s[i] );
    job_Guarantee_Int_Arg( i );
    return j;
}

/************************************************************************/
/*-    job_get_boolean --						*/
/************************************************************************/
static GLboolean
job_get_boolean(
    int i
) {
    GLboolean j = OBJ_TO_INT( jS.s[i] );
    job_Guarantee_Int_Arg( i );
    return j;
}

/************************************************************************/
/*-    job_get_float --							*/
/************************************************************************/
static GLfloat
job_get_float(
    int i
) {
    job_Guarantee_Float_Arg( i );
    return OBJ_TO_FLOAT( jS.s[i] );
}

/************************************************************************/
/*-    job_get_double --						*/
/************************************************************************/
static GLdouble
job_get_double(
    int i
) {
    job_Guarantee_Float_Arg( i );
    return OBJ_TO_FLOAT( jS.s[i] );
}

/************************************************************************/
/*-    job_get_int --							*/
/************************************************************************/
static GLint
job_get_int(
    int i
) {
    job_Guarantee_Int_Arg( i );
    return OBJ_TO_INT( jS.s[i] );
}

/************************************************************************/
/*-    job_P_Glu_New_Quadric --						*/
/************************************************************************/
void
job_P_Glu_New_Quadric(
    void
) {
    quadric_clock = (quadric_clock+1) & JOB_QUADRIC_MASK;

    /* Recycle any pre-existing quadric in this slot:  */
    if (quadric[ quadric_clock ]) {
	gluDeleteQuadric( quadric[ quadric_clock ] );
    }

    /* Allocate new quadric:  */
    quadric[ quadric_clock ] = gluNewQuadric();

    ++jS.s;
    if (!quadric[ quadric_clock ])   *jS.s = OBJ_NIL;
    else                             *jS.s = OBJ_FROM_INT(quadric_clock);
}
/************************************************************************/
/*-    job_P_Glu_Delete_Quadric --					*/
/************************************************************************/
void
job_P_Glu_Delete_Quadric(
    void
) {
    gluDeleteQuadric( job_get_glu_quadric(0) );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Glu_Quadric_Draw_Style --					*/
/************************************************************************/
void
job_P_Glu_Quadric_Draw_Style(
    void
) {
    GLUquadricObj* quad = job_get_glu_quadric(-1);
    GLenum         draw = job_get_enum(        0);
    gluQuadricDrawStyle( quad, draw );
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Glu_Quadric_Orientation --					*/
/************************************************************************/
void
job_P_Glu_Quadric_Orientation(
    void
) {
    GLUquadricObj* quad     = job_get_glu_quadric(-1);
    GLenum      orientation = job_get_enum(        0);
    gluQuadricOrientation( quad, orientation );
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Glu_Quadric_Normals --					*/
/************************************************************************/
void
job_P_Glu_Quadric_Normals(
    void
) {
    GLUquadricObj* quad        = job_get_glu_quadric(-1);
    GLenum         normal      = job_get_enum(        0);
    gluQuadricNormals( quad, normal );
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Glu_Quadric_Texture --					*/
/************************************************************************/
void
job_P_Glu_Quadric_Texture(
    void
) {
    GLUquadricObj* quad    = job_get_glu_quadric(-1);
    GLboolean      texture = job_get_boolean(     0);
    gluQuadricTexture( quad, texture );
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Glu_Quadric_Callback --					*/
/************************************************************************/
void
job_P_Glu_Quadric_Callback(
    void
) {
    MUQ_WARN("job_P_Glu_Quadric_Callback unimplemented");
}
/************************************************************************/
/*-    job_P_Glu_Cylinder --						*/
/************************************************************************/
void
job_P_Glu_Cylinder(
    void
) {
    job_Guarantee_N_Args(  6 );
    {   GLUquadricObj* quad   = job_get_glu_quadric(-5);
	GLdouble       base   = job_get_double(     -4);
	GLdouble       top    = job_get_double(     -3);
	GLdouble       high   = job_get_double(     -2);
	GLint          slices = job_get_int(        -1);
	GLint          stacks = job_get_int(         0);
        gluCylinder( quad, base, top, high, slices, stacks );
    }
    jS.s -= 6;
}
/************************************************************************/
/*-    job_P_Glu_Sphere --						*/
/************************************************************************/
void
job_P_Glu_Sphere(
    void
) {
    job_Guarantee_N_Args(  4 );
    {   GLUquadricObj* quad   = job_get_glu_quadric(-3);
	GLdouble       radius = job_get_double(     -2);
	GLint          slices = job_get_int(        -1);
	GLint          stacks = job_get_int(         0);
        gluSphere( quad, radius, slices, stacks );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Glu_Disk --						*/
/************************************************************************/
void
job_P_Glu_Disk(
    void
) {
    job_Guarantee_N_Args(  5 );
    {   GLUquadricObj* quad   = job_get_glu_quadric(-4);
	GLdouble       inner  = job_get_double(     -3);
	GLdouble       outer  = job_get_double(     -2);
	GLint          slices = job_get_int(        -1);
	GLint          loops  = job_get_int(         0);
        gluDisk( quad, inner, outer, slices, loops );
    }
    jS.s -= 5;
}
/************************************************************************/
/*-    job_P_Glu_Partial_Disk --					*/
/************************************************************************/
void
job_P_Glu_Partial_Disk(
    void
) {
    job_Guarantee_N_Args(  7 );
    {   GLUquadricObj* quad   = job_get_glu_quadric(-6);
	GLdouble       inner  = job_get_double(     -5);
	GLdouble       outer  = job_get_double(     -4);
	GLint          slices = job_get_int(        -3);
	GLint          loops  = job_get_int(        -2);
	GLdouble       start  = job_get_double(     -1);
	GLdouble       sweep  = job_get_double(      0);
        gluPartialDisk( quad, inner, outer, slices, loops, start, sweep );
    }
    jS.s -= 7;
}
/************************************************************************/
/*-    nurb cache --							*/
/************************************************************************/

#define JOB_NURB_MAX 16	/* Must be a power of two */
#define JOB_NURB_MASK (JOB_NURB_MAX-1)
static GLUnurbsObj* nurb[JOB_NURB_MAX];
static unsigned int nurb_clock = 0;

/************************************************************************/
/*-    job_get_glu_nurb --						*/
/************************************************************************/
static GLUnurbsObj*
job_get_glu_nurb(
    int i
) {
    Vm_Int j = OBJ_TO_INT( jS.s[i] );
    job_Guarantee_Int_Arg( i );
    if (j & ~JOB_NURB_MASK
    || !nurb[j]
    ){
        MUQ_WARN ("Needed glu nurb argument at top-of-stack[%d]", (int)i );
    }
    return nurb[j];
}

/************************************************************************/
/*-    job_P_Glu_New_Nurbs_Renderer --					*/
/************************************************************************/
void
job_P_Glu_New_Nurbs_Renderer(
    void
) {
    nurb_clock = (nurb_clock+1) & JOB_NURB_MASK;

    /* Recycle any pre-existing nurb in this slot:  */
    if (nurb[ nurb_clock ]) {
	gluDeleteNurbsRenderer( nurb[ nurb_clock ] );
    }

    /* Allocate new nurb:  */
    nurb[ nurb_clock ] = gluNewNurbsRenderer();

    ++jS.s;
    if (!nurb[ nurb_clock ])   *jS.s = OBJ_NIL;
    else                       *jS.s = OBJ_FROM_INT(nurb_clock);
}
/************************************************************************/
/*-    job_P_Glu_Delete_Nurbs_Renderer --				*/
/************************************************************************/
void
job_P_Glu_Delete_Nurbs_Renderer(
    void
) {
    gluDeleteNurbsRenderer( job_get_glu_nurb(0) );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Glu_Load_Sampling_Matrices --				*/
/************************************************************************/
void
job_P_Glu_Load_Sampling_Matrices(
    void
) {
    job_Guarantee_N_Args(   4 );
    job_Guarantee_F32_Len( -2, 16 );
    job_Guarantee_F32_Len( -1, 16 );
    job_Guarantee_I32_Len(  0,  4 );
    {   GLUnurbsObj* nurb   = job_get_glu_nurb(-3);
        F32_P        model  = NULL;	/* Just to quiet compilers. */
	F32_P        persp  = NULL;	/* Just to quiet compilers. */
	I32_P        view   = NULL;	/* Just to quiet compilers. */
	vm_Loc3(
	    (void**)&model,
	    (void**)&persp,
	    (void**)&view,
	    jS.s[-2],
	    jS.s[-1],
	    jS.s[ 0]
        );
	gluLoadSamplingMatrices( nurb, &model->slot[0], &persp->slot[0], &view->slot[0] );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Glu_Nurbs_Property --					*/
/************************************************************************/
void
job_P_Glu_Nurbs_Property(
    void
) {
    job_Guarantee_N_Args(  3 );
    {   GLUnurbsObj*  nurb     = job_get_glu_nurb(-2);
	GLenum        property = job_get_enum(    -1);
	GLfloat       value    = job_get_float(    0);
        gluNurbsProperty( nurb, property, value );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Glu_Get_Nurbs_Property --					*/
/************************************************************************/
void
job_P_Glu_Get_Nurbs_Property(
    void
) {
    job_Guarantee_N_Args(  2 );
    {   GLUnurbsObj*  nurb     = job_get_glu_nurb(-1);
	GLenum        property = job_get_enum(     0);
	GLfloat       result   = 0.0;	/* Just to quiet compilers.	*/
	gluGetNurbsProperty( nurb, property, &result );
	*--jS.s = OBJ_FROM_FLOAT(result);
    }
}
/************************************************************************/
/*-    job_P_Glu_Begin_Curve --						*/
/************************************************************************/
void
job_P_Glu_Begin_Curve(
    void
) {
    gluBeginCurve( job_get_glu_nurb(0) );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Glu_End_Curve --						*/
/************************************************************************/
void
job_P_Glu_End_Curve(
    void
) {
    gluEndCurve( job_get_glu_nurb(0) );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Glu_Nurbs_Curve --						*/
/************************************************************************/
void
job_P_Glu_Nurbs_Curve(
    void
) {
    job_Guarantee_N_Args(   7 );
    job_Guarantee_F32_Arg( -4 );
    job_Guarantee_F32_Arg( -2 );
    {   GLUnurbsObj*  nurb      = job_get_glu_nurb(-6);
	GLint         knotCount = job_get_int(     -5);
	GLint         stride    = job_get_int(     -3);
	GLint         order     = job_get_int(     -1);
	GLenum        type      = job_get_enum(     0);
        F32_P         knots     = NULL;	/* Just to quiet compilers. */
        F32_P         control   = NULL;	/* Just to quiet compilers. */
	vm_Loc2( (void**)&knots, (void**)&control, jS.s[-4], jS.s[-2] );
	/* Buggo, we probably need some sanity checking here    */
	/* to catch malicious values of stride/knotCount/order: */
	gluNurbsCurve(
	    nurb,
	    knotCount,
	    &knots->slot[0],
	    stride,
	    &control->slot[0],
	    order,
	    type
	);
    }
    jS.s -= 7;
}
/************************************************************************/
/*-    job_P_Glu_Begin_Surface --					*/
/************************************************************************/
void
job_P_Glu_Begin_Surface(
    void
) {
    gluBeginSurface( job_get_glu_nurb(0) );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Glu_End_Surface --						*/
/************************************************************************/
void
job_P_Glu_End_Surface(
    void
) {
    gluEndSurface( job_get_glu_nurb(0) );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Glu_Nurbs_Surface --					*/
/************************************************************************/
void
job_P_Glu_Nurbs_Surface(
    void
) {
    job_Guarantee_N_Args(   11 );
    job_Guarantee_F32_Arg(  -8 );
    job_Guarantee_F32_Arg(  -6 );
    job_Guarantee_F32_Arg(  -3 );
    {   GLUnurbsObj*  nurb       = job_get_glu_nurb( -10 );
	GLint         sKnotCount = job_get_int(       -9 );
	GLint         tKnotCount = job_get_int(       -7 );
	GLint         sStride    = job_get_int(       -5 );
	GLint         tStride    = job_get_int(       -4 );
	GLint         sOrder     = job_get_int(       -2 );
	GLint         tOrder     = job_get_int(       -1 );
	GLenum        type       = job_get_enum(       0 );
        F32_P         sKnots     = NULL;	/* Just to quiet compilers. */
        F32_P         tKnots     = NULL;	/* Just to quiet compilers. */
        F32_P         control    = NULL;	/* Just to quiet compilers. */
	vm_Loc3( (void**)&sKnots, (void**)&tKnots, (void**)&control, jS.s[-8], jS.s[-6], jS.s[-3] );
	/* Buggo, we probably need some sanity checking here    */
	/* to catch malicious values of stride/knotCount/order: */
	gluNurbsSurface(
	    nurb,
	    sKnotCount,
	    &sKnots->slot[0],
	    tKnotCount,
	    &tKnots->slot[0],
	    sStride,
	    tStride,
	    &control->slot[0],
	    sOrder,
	    tOrder,
	    type
	);
    }
    jS.s -= 11;
}
/************************************************************************/
/*-    job_P_Glu_Begin_Trim --						*/
/************************************************************************/
void
job_P_Glu_Begin_Trim(
    void
) {
    gluBeginTrim( job_get_glu_nurb(0) );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Glu_End_Trim --						*/
/************************************************************************/
void
job_P_Glu_End_Trim(
    void
) {
    gluEndTrim( job_get_glu_nurb(0) );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Glu_Pwl_Curve --						*/
/************************************************************************/
void
job_P_Glu_Pwl_Curve(
    void
) {
    job_Guarantee_N_Args(    5 );
    job_Guarantee_F32_Arg(  -2 );
    {   GLUnurbsObj*  nurb       = job_get_glu_nurb( -4 );
        GLint         count      = job_get_int(      -3 );
	GLint         stride     = job_get_int(      -1 );
	GLenum        type       = job_get_enum(      0 );
        F32_P         data       = vm_Loc(jS.s[-2]);
	/* Buggo, we probably need some sanity checking here */
	/* to catch malicious values of stride/count:        */
	gluPwlCurve(
	    nurb,
	    count,
	    &data->slot[0],
	    stride,
	    type
	);
    }
    jS.s -= 5;
}
/************************************************************************/
/*-    job_P_Glu_Nurbs_Callback --					*/
/************************************************************************/
void
job_P_Glu_Nurbs_Callback(
    void
) {
    MUQ_WARN("job_P_Glu_Nurbs_Callback unimplemented");
}
/************************************************************************/
/*-    tess cache --							*/
/************************************************************************/

#define JOB_TESS_MAX 16	/* Must be a power of two */
#define JOB_TESS_MASK (JOB_TESS_MAX-1)
static GLUtriangulatorObj* tess[JOB_TESS_MAX];
static unsigned int tess_clock = 0;

/************************************************************************/
/*-    job_get_glu_tess --						*/
/************************************************************************/
static GLUtriangulatorObj*
job_get_glu_tess(
    int i
) {
    Vm_Int j = OBJ_TO_INT( jS.s[i] );
    job_Guarantee_Int_Arg( i );
    if (j & ~JOB_TESS_MASK
    || !tess[j]
    ){
        MUQ_WARN ("Needed glu tesselator argument at top-of-stack[%d]", (int)i );
    }
    return tess[j];
}

/************************************************************************/
/*-    job_P_Glu_New_Tess --						*/
/************************************************************************/
void
job_P_Glu_New_Tess(
    void
) {
    tess_clock = (tess_clock+1) & JOB_TESS_MASK;

    /* Recycle any pre-existing tesselator in this slot:  */
    if (tess[ tess_clock ]) {
	gluDeleteTess( tess[ tess_clock ] );
    }

    /* Allocate new nurb:  */
    tess[ tess_clock ] = gluNewTess();

    ++jS.s;
    if (!tess[ tess_clock ])   *jS.s = OBJ_NIL;
    else                       *jS.s = OBJ_FROM_INT(tess_clock);
}
/************************************************************************/
/*-    job_P_Glu_Tess_Callback --					*/
/************************************************************************/
void
job_P_Glu_Tess_Callback(
    void
) {
    MUQ_WARN("job_P_Glu_Tess_Callback unimplemented");
}
/************************************************************************/
/*-    job_P_Glu_Delete_Tess --						*/
/************************************************************************/
void
job_P_Glu_Delete_Tess(
    void
) {
    gluDeleteTess( job_get_glu_tess(0) );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Glu_Begin_Polygon --					*/
/************************************************************************/
void
job_P_Glu_Begin_Polygon(
    void
) {
    gluBeginPolygon( job_get_glu_tess(0) );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Glu_End_Polygon --						*/
/************************************************************************/
void
job_P_Glu_End_Polygon(
    void
) {
    gluEndPolygon( job_get_glu_tess(0) );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Glu_Next_Contour --					*/
/************************************************************************/
void
job_P_Glu_Next_Contour(
    void
) {
    job_Guarantee_N_Args(    2 );
    {   GLUtriangulatorObj*  tess  = job_get_glu_tess( -1 );
	GLenum               type  = job_get_enum(      0 );
	gluNextContour( tess, type );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Glu_Tess_Vertex --						*/
/************************************************************************/
void
job_P_Glu_Tess_Vertex(
    void
) {
  /* buggo, need to think carefully about the potential */
  /* for overwriting data, before enabling this one:    */
    MUQ_WARN("job_P_Glu_Tess_Vertex unimplemented");
    job_Guarantee_N_Args(    3 );
    job_Guarantee_F64_Arg(  -1 );
    job_Guarantee_F32_Arg(   0 );
    {   GLUtriangulatorObj*  tess     = job_get_glu_tess( -2 );
        F64_P                location = NULL;	/* Just to quiet compilers. */
        F32_P                data     = NULL;
	vm_Loc2( (void**)&location, (void**)&data, jS.s[-1], jS.s[0] );
	gluTessVertex( tess, &location->slot[0], &data->slot[0] );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Glu_Get_String --						*/
/************************************************************************/
void
job_P_Glu_Get_String(
    void
) {
    GLenum name = OBJ_TO_INT( *jS.s );
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    *jS.s = stg_From_Asciz( (Vm_Uch*)gluGetString( name ) );
}

/************************************************************************/
/*-    job_P_Gl_Clear_Index						*/
/************************************************************************/

void
job_P_Gl_Clear_Index(
    void
){
    GLfloat c = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glClearIndex(c);
    --jS.s;
}

/************************************************************************/
/*-    job_P_Gl_Clear_Color						*/
/************************************************************************/

void
job_P_Gl_Clear_Color(
    void
){
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLclampf red   = OBJ_TO_FLOAT( jS.s[-3] );
        GLclampf green = OBJ_TO_FLOAT( jS.s[-2] );
        GLclampf blue  = OBJ_TO_FLOAT( jS.s[-1] );
        GLclampf alpha = OBJ_TO_FLOAT( jS.s[ 0] );
	glClearColor( red, green, blue, alpha );
    }
    jS.s -= 4;
}

/************************************************************************/
/*-    job_P_Gl_Clear --						*/
/************************************************************************/

void
job_P_Gl_Clear(
    void
) {
    GLbitfield b = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glClear(b);
    --jS.s;
}

/************************************************************************/
/*-    job_P_Gl_Index_Mask						*/
/************************************************************************/

void
job_P_Gl_Index_Mask(
    void
){
    GLuint mask = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glIndexMask(mask);
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Color_Mask						*/
/************************************************************************/

void
job_P_Gl_Color_Mask(
    void
){
    job_Guarantee_N_Args(   4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLboolean red   = OBJ_TO_INT( jS.s[-3] );
        GLboolean green = OBJ_TO_INT( jS.s[-2] );
        GLboolean blue  = OBJ_TO_INT( jS.s[-1] );
        GLboolean alpha = OBJ_TO_INT( jS.s[ 0] );
	glColorMask( red, green, blue, alpha );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Alpha_Func						*/
/************************************************************************/

void
job_P_Gl_Alpha_Func(
    void
){
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Int_Arg(   -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLenum   func = OBJ_TO_INT(   jS.s[-1] );
        GLclampf ref  = OBJ_TO_FLOAT( jS.s[ 0] );
	glAlphaFunc( func, ref );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Blend_Func						*/
/************************************************************************/

void
job_P_Gl_Blend_Func(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum sfactor = OBJ_TO_INT( jS.s[-1] );
        GLenum dfactor = OBJ_TO_INT( jS.s[ 0] );
	glBlendFunc( sfactor, dfactor );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Logic_Op						*/
/************************************************************************/

void
job_P_Gl_Logic_Op(
    void
){
    GLenum opcode = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glLogicOp(opcode);
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Cull_Face						*/
/************************************************************************/

void
job_P_Gl_Cull_Face(
    void
){
    GLenum mode = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glCullFace(mode);
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Front_Face						*/
/************************************************************************/

void
job_P_Gl_Front_Face(
    void
){
    GLenum mode = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glFrontFace(mode);
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Point_Size						*/
/************************************************************************/

void
job_P_Gl_Point_Size(
    void
){
    job_Guarantee_N_Args(     1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat size = OBJ_TO_INT(   jS.s[0] );
	glPointSize( size );
    }
    jS.s -= 1;
}
/************************************************************************/
/*-    job_P_Gl_Line_Width						*/
/************************************************************************/

void
job_P_Gl_Line_Width(
    void
){
    job_Guarantee_N_Args(     1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat width = OBJ_TO_INT(   jS.s[0] );
	glLineWidth( width );
    }
    jS.s -= 1;
}
/************************************************************************/
/*-    job_P_Gl_Line_Stipple						*/
/************************************************************************/

void
job_P_Gl_Line_Stipple(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLint   factor   = OBJ_TO_INT( jS.s[-1] );
        GLushort pattern = OBJ_TO_INT( jS.s[ 0] );
	glLineStipple( factor, pattern );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Polygon_Mode						*/
/************************************************************************/

void
job_P_Gl_Polygon_Mode(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum face = OBJ_TO_INT( jS.s[-1] );
        GLenum mode = OBJ_TO_INT( jS.s[ 0] );
	glPolygonMode( face, mode );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Polygon_Offset						*/
/************************************************************************/

void
job_P_Gl_Polygon_Offset(
    void
){
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat factor = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat units  = OBJ_TO_FLOAT( jS.s[ 0] );
	glPolygonOffset( factor, units );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Polygon_Stipple						*/
/************************************************************************/

void
job_P_Gl_Polygon_Stipple(
    void
){
    /* Need a 32x32==1024 unsigned byte string argument: */
    job_Guarantee_Stg_Arg( 0 );
    {	Vm_Obj stg = jS.s[0];
    	Vm_Int len = stg_Len( stg );
	GLubyte buf[ 1024 ];
	job_Guarantee_Headroom( len+2 );
	if (len != 1024) MUQ_WARN ("glPolygonStipple arg must be 32x32==1024 bytes");
	if (len != stg_Get_Bytes( (Vm_Uch*)buf, len, stg, 0 )) {
	    MUQ_WARN ("glPolygonStipple: internal error");
	}
        glPolygonStipple( buf );
    }
}
/************************************************************************/
/*-    job_P_Gl_Get_Polygon_Stipple					*/
/************************************************************************/

void
job_P_Gl_Get_Polygon_Stipple(
    void
){
    /* Need a 32x32==1024 unsigned byte string argument: */
    job_Guarantee_Stg_Arg(   0 );
    job_Must_Control_Object( 0 );
    {	Vm_Obj stg = jS.s[0];
    	Vm_Int len = stg_Len( stg );
	GLubyte buf[ 1024 ];
	job_Guarantee_Headroom( len+2 );
	if (len != 1024) MUQ_WARN ("glGetPolygonStipple arg must be 32x32==1024 bytes");
        glGetPolygonStipple( buf );
	if (len != stg_Set_Bytes( (Vm_Uch*)buf, len, stg, 0 )) {
	    MUQ_WARN ("glPolygonStipple: internal error");
	}
    }
}
/************************************************************************/
/*-    job_P_Gl_Edge_Flag						*/
/************************************************************************/

void
job_P_Gl_Edge_Flag(
    void
){
    GLboolean flag = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glEdgeFlag(flag);
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Edge_Flagv						*/
/************************************************************************/

void
job_P_Gl_Edge_Flagv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Stg_Arg( 0 );
    {	Vm_Obj stg = jS.s[0];
    	Vm_Int len = stg_Len( stg );
	GLubyte buf[ 4 ];
	if (len != 1) MUQ_WARN ("glEdgeFlagV arg must be one-byte string");
	if (len != stg_Get_Bytes( (Vm_Uch*)buf, len, stg, 0 )) {
	    MUQ_WARN ("glEdgeFlagv: internal error");
	}
        glEdgeFlagv( buf );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Scissor							*/
/************************************************************************/

void
job_P_Gl_Scissor(
    void
){
    job_Guarantee_N_Args(   4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLint     x     = OBJ_TO_INT( jS.s[-3] );
        GLint     y     = OBJ_TO_INT( jS.s[-2] );
        GLsizei   wide  = OBJ_TO_INT( jS.s[-1] );
        GLsizei   high  = OBJ_TO_INT( jS.s[ 0] );
	glScissor( x, y, wide, high );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Clip_Plane						*/
/************************************************************************/

void
job_P_Gl_Clip_Plane(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_F64_Arg(  0 );
    if (f64_Len(jS.s[-1])!=4) MUQ_WARN("glClipPlane needs eqn vector len==4");
    {   GLint     plane  = OBJ_TO_INT( jS.s[-1] );
        GLdouble  eqn[4];
	Vm_Flt64* p = &F64_P(jS.s[0])->slot[0];
	eqn[0] = p[0];
	eqn[1] = p[1];
	eqn[2] = p[2];
	eqn[3] = p[3];
	if (plane < GL_CLIP_PLANE0 || plane >= GL_MAX_CLIP_PLANES) {
	    MUQ_WARN("glClipPlane: invalid 'plane' parameter");
	}
	glClipPlane( plane, eqn );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Get_Clip_Plane						*/
/************************************************************************/

void
job_P_Gl_Get_Clip_Plane(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_F64_Arg(  0 );
    if (f64_Len(jS.s[-1])!=4)MUQ_WARN("glGetClipPlane needs eqn vector len==4");
    {   GLint     plane  = OBJ_TO_INT( jS.s[-1] );
        GLdouble  eqn[4];
	if (plane < GL_CLIP_PLANE0 || plane >= GL_MAX_CLIP_PLANES) {
	    MUQ_WARN("glGetClipPlane: invalid 'plane' parameter");
	}
	glClipPlane( plane, eqn );
	{   Vm_Flt64* p = &F64_P(jS.s[0])->slot[0];
	    p[0] = eqn[0];
	    p[1] = eqn[1];
	    p[2] = eqn[2];
	    p[3] = eqn[3];
	}
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Draw_Buffer						*/
/************************************************************************/

void
job_P_Gl_Draw_Buffer(
    void
){
    int u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glDrawBuffer(u);
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Read_Buffer						*/
/************************************************************************/

void
job_P_Gl_Read_Buffer(
    void
){
    int u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glReadBuffer(u);
    --jS.s;
}

/************************************************************************/
/*-    job_P_Gl_Enable --						*/
/************************************************************************/

void
job_P_Gl_Enable(
    void
) {
    int u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glEnable(u);
    --jS.s;
}

/************************************************************************/
/*-    job_P_Gl_Disable							*/
/************************************************************************/

void
job_P_Gl_Disable(
    void
){
    GLenum u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glDisable(u);
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Is_Enabled						*/
/************************************************************************/

void
job_P_Gl_Is_Enabled(
    void
){
    GLenum u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    u = glIsEnabled(u);
    *jS.s = OBJ_FROM_INT(u);
}
/************************************************************************/
/*-    job_P_Gl_Enable_Client_State					*/
/************************************************************************/

void
job_P_Gl_Enable_Client_State(
    void
){
    int u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glEnableClientState(u);
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Disable_Client_State					*/
/************************************************************************/

void
job_P_Gl_Disable_Client_State(
    void
){
    int u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glDisableClientState(u);
    --jS.s;
}
/************************************************************************/
/*-    job_get_return_value_count					*/
/************************************************************************/
static int
job_get_return_value_count(
    GLenum pname
) {
    switch (pname) {
    case GL_ACCUM_ALPHA_BITS:			return 1;
    case GL_ACCUM_BLUE_BITS:			return 1;
    case GL_ACCUM_CLEAR_VALUE:			return 4;
    case GL_ACCUM_GREEN_BITS:			return 1;

    case GL_ACCUM_RED_BITS:			return 1;
    case GL_ALPHA_BIAS:				return 1;
    case GL_ALPHA_BITS:				return 1;
    case GL_ALPHA_SCALE:			return 1;

    case GL_ALPHA_TEST:				return 1;
    case GL_ALPHA_TEST_FUNC:			return 1;
    case GL_ALPHA_TEST_REF:			return 1;
    case GL_ATTRIB_STACK_DEPTH:			return 1;

    case GL_AUTO_NORMAL:			return 1;
    case GL_AUX_BUFFERS:			return 1;
    case GL_BLEND:				return 1;
    case GL_BLEND_DST:				return 1;

    case GL_BLEND_SRC:				return 1;
    case GL_BLUE_BIAS:				return 1;
    case GL_BLUE_BITS:				return 1;
    case GL_BLUE_SCALE:				return 1;

    case GL_CLIENT_ATTRIB_STACK_DEPTH:		return 1;
    case GL_CLIP_PLANE0:			return 1;
    case GL_CLIP_PLANE1:			return 1;
    case GL_CLIP_PLANE2:			return 1;

    case GL_CLIP_PLANE3:			return 1;
    case GL_CLIP_PLANE4:			return 1;
    case GL_CLIP_PLANE5:			return 1;
    case GL_COLOR_ARRAY:			return 1;

    case GL_COLOR_ARRAY_SIZE:			return 1;
    case GL_COLOR_ARRAY_STRIDE:			return 1;
    case GL_COLOR_ARRAY_TYPE:			return 1;
    case GL_COLOR_CLEAR_VALUE:			return 4;

    case GL_COLOR_LOGIC_OP:			return 1;
    case GL_COLOR_MATERIAL:			return 1;
    case GL_COLOR_MATERIAL_FACE:		return 1;
    case GL_COLOR_MATERIAL_PARAMETER:		return 1;

    case GL_COLOR_WRITEMASK:			return 4;
    case GL_CULL_FACE:				return 1;
    case GL_CULL_FACE_MODE:			return 1;
    case GL_CURRENT_COLOR:			return 4;

    case GL_CURRENT_INDEX:			return 1;
    case GL_CURRENT_NORMAL:			return 3;
    case GL_CURRENT_RASTER_COLOR:		return 4;
    case GL_CURRENT_RASTER_DISTANCE:		return 1;

    case GL_CURRENT_RASTER_INDEX:		return 1;
    case GL_CURRENT_RASTER_POSITION:		return 4;
    case GL_CURRENT_RASTER_POSITION_VALID:	return 1;
    case GL_CURRENT_RASTER_TEXTURE_COORDS:	return 4;

    case GL_CURRENT_TEXTURE_COORDS:		return 1;
    case GL_DEPTH_BIAS:				return 1;
    case GL_DEPTH_BITS:				return 1;
    case GL_DEPTH_CLEAR_VALUE:			return 1;

    case GL_DEPTH_FUNC:				return 1;
    case GL_DEPTH_RANGE:			return 2;
    case GL_DEPTH_SCALE:			return 1;
    case GL_DEPTH_TEST:				return 1;

    case GL_DEPTH_WRITEMASK:			return 1;
    case GL_DITHER:				return 1;
    case GL_DOUBLEBUFFER:			return 1;
    case GL_DRAW_BUFFER:			return 1;

    case GL_EDGE_FLAG:				return 1;
    case GL_EDGE_FLAG_ARRAY:			return 1;
    case GL_EDGE_FLAG_ARRAY_STRIDE:		return 1;
    case GL_FOG:				return 1;

    case GL_FOG_COLOR:				return 4;
    case GL_FOG_DENSITY:			return 1;
    case GL_FOG_END:				return 1;
    case GL_FOG_HINT:				return 1;

    case GL_FOG_INDEX:				return 1;
    case GL_FOG_MODE:				return 1;
    case GL_FOG_START:				return 1;
    case GL_FRONT_FACE:				return 1;

    case GL_GREEN_BIAS:				return 1;
    case GL_GREEN_BITS:				return 1;
    case GL_GREEN_SCALE:			return 1;
    case GL_INDEX_ARRAY:			return 1;

    case GL_INDEX_ARRAY_STRIDE:			return 1;
    case GL_INDEX_ARRAY_TYPE:			return 1;
    case GL_INDEX_BITS:				return 1;
    case GL_INDEX_CLEAR_VALUE:			return 1;

    case GL_INDEX_LOGIC_OP:			return 1;
    case GL_INDEX_MODE:				return 1;
    case GL_INDEX_OFFSET:			return 1;
    case GL_INDEX_SHIFT:			return 1;

    case GL_INDEX_WRITEMASK:			return 1;
    case GL_LIGHT0:				return 1;
    case GL_LIGHT1:				return 1;
    case GL_LIGHT2:				return 1;
	    
    case GL_LIGHT3:				return 1;
    case GL_LIGHT4:				return 1;
    case GL_LIGHT5:				return 1;
    case GL_LIGHT6:				return 1;
	    
    case GL_LIGHT7:				return 1;
    case GL_LIGHTING:				return 1;
    case GL_LIGHT_MODEL_AMBIENT:		return 4;
    case GL_LIGHT_MODEL_LOCAL_VIEWER:		return 1;

    case GL_LIGHT_MODEL_TWO_SIDE:		return 1;
    case GL_LINE_SMOOTH:			return 1;
    case GL_LINE_SMOOTH_HINT:			return 1;
    case GL_LINE_STIPPLE:			return 1;

    case GL_LINE_STIPPLE_PATTERN:		return 1;
    case GL_LINE_STIPPLE_REPEAT:		return 1;
    case GL_LINE_WIDTH:				return 1;
    case GL_LINE_WIDTH_GRANULARITY:		return 1;

    case GL_LINE_WIDTH_RANGE:			return 2;
    case GL_LIST_BASE:				return 1;
    case GL_LIST_INDEX:				return 1;
    case GL_LIST_MODE:				return 1;

    case GL_LOGIC_OP_MODE:			return 1;
    case GL_MAP1_COLOR_4:			return 1;
    case GL_MAP1_GRID_DOMAIN:			return 2;
    case GL_MAP1_GRID_SEGMENTS:			return 1;

    case GL_MAP1_INDEX:				return 1;
    case GL_MAP1_NORMAL:			return 1;
    case GL_MAP1_TEXTURE_COORD_1:		return 1;
    case GL_MAP1_TEXTURE_COORD_2:		return 1;

    case GL_MAP1_TEXTURE_COORD_3:		return 1;
    case GL_MAP1_TEXTURE_COORD_4:		return 1;
    case GL_MAP1_VERTEX_3:			return 1;
    case GL_MAP1_VERTEX_4:			return 1;

    case GL_MAP2_COLOR_4:			return 1;
    case GL_MAP2_GRID_DOMAIN:			return 2;
    case GL_MAP2_GRID_SEGMENTS:			return 1;
    case GL_MAP2_INDEX:				return 1;

    case GL_MAP2_NORMAL:			return 1;
    case GL_MAP2_TEXTURE_COORD_1:		return 1;
    case GL_MAP2_TEXTURE_COORD_2:		return 1;
    case GL_MAP2_TEXTURE_COORD_3:		return 1;

    case GL_MAP2_TEXTURE_COORD_4:		return 1;
    case GL_MAP2_VERTEX_3:			return 1;
    case GL_MAP2_VERTEX_4:			return 1;
    case GL_MAP_COLOR:				return 1;

    case GL_MAP_STENCIL:			return 1;
    case GL_MATRIX_MODE:			return 1;
    case GL_MAX_CLIENT_ATTRIB_STACK_DEPTH:	return 1;
    case GL_MAX_ATTRIB_STACK_DEPTH:		return 1;

    case GL_MAX_CLIP_PLANES:			return 1;
    case GL_MAX_EVAL_ORDER:			return 1;
    case GL_MAX_LIGHTS:				return 1;
    case GL_MAX_LIST_NESTING:			return 1;

    case GL_MAX_MODELVIEW_STACK_DEPTH:		return 1;
    case GL_MAX_NAME_STACK_DEPTH:		return 1;
    case GL_MAX_PIXEL_MAP_TABLE:		return 1;
    case GL_MAX_PROJECTION_STACK_DEPTH:		return 1;

    case GL_MAX_TEXTURE_SIZE:			return 1;
    case GL_MAX_TEXTURE_STACK_DEPTH:		return 1;
    case GL_MAX_VIEWPORT_DIMS:			return 2;
    case GL_MODELVIEW_MATRIX:			return 16;

    case GL_MODELVIEW_STACK_DEPTH:		return 1;
    case GL_NAME_STACK_DEPTH:			return 1;
    case GL_NORMAL_ARRAY:			return 1;
    case GL_NORMAL_ARRAY_STRIDE:		return 1;

    case GL_NORMAL_ARRAY_TYPE:			return 1;
    case GL_NORMALIZE:				return 1;
    case GL_PACK_ALIGNMENT:			return 1;
    case GL_PACK_LSB_FIRST:			return 1;

    case GL_PACK_ROW_LENGTH:			return 1;
    case GL_PACK_SKIP_PIXELS:			return 1;
    case GL_PACK_SKIP_ROWS:			return 1;
    case GL_PACK_SWAP_BYTES:			return 1;

    case GL_PERSPECTIVE_CORRECTION_HINT:	return 1;
    case GL_PIXEL_MAP_A_TO_A_SIZE:		return 1;
    case GL_PIXEL_MAP_B_TO_B_SIZE:		return 1;
    case GL_PIXEL_MAP_G_TO_G_SIZE:		return 1;

    case GL_PIXEL_MAP_I_TO_A_SIZE:		return 1;
    case GL_PIXEL_MAP_I_TO_B_SIZE:		return 1;
    case GL_PIXEL_MAP_I_TO_G_SIZE:		return 1;
    case GL_PIXEL_MAP_I_TO_I_SIZE:		return 1;

    case GL_PIXEL_MAP_I_TO_R_SIZE:		return 1;
    case GL_PIXEL_MAP_R_TO_R_SIZE:		return 1;
    case GL_PIXEL_MAP_S_TO_S_SIZE:		return 1;
    case GL_POINT_SIZE:				return 1;

    case GL_POINT_SIZE_GRANULARITY:		return 1;
    case GL_POINT_SIZE_RANGE:			return 2;
    case GL_POINT_SMOOTH:			return 1;
    case GL_POINT_SMOOTH_HINT:			return 1;

    case GL_POLYGON_MODE:			return 2;
    case GL_POLYGON_OFFSET_FACTOR:		return 1;
    case GL_POLYGON_OFFSET_UNITS:		return 1;
    case GL_POLYGON_OFFSET_FILL:		return 1;

    case GL_POLYGON_OFFSET_LINE:		return 1;
    case GL_POLYGON_OFFSET_POINT:		return 1;
    case GL_POLYGON_SMOOTH:			return 1;
    case GL_POLYGON_SMOOTH_HINT:		return 1;

    case GL_POLYGON_STIPPLE:			return 1;
    case GL_PROJECTION_MATRIX:			return 16;
    case GL_PROJECTION_STACK_DEPTH:		return 1;
    case GL_READ_BUFFER:			return 1;

    case GL_RED_BIAS:				return 1;
    case GL_RED_BITS:				return 1;
    case GL_RED_SCALE:				return 1;
    case GL_RENDER_MODE:			return 1;

    case GL_RGBA_MODE:				return 1;
    case GL_SCISSOR_BOX:			return 4;
    case GL_SCISSOR_TEST:			return 1;
    case GL_SHADE_MODEL:			return 1;

    case GL_STENCIL_BITS:			return 1;
    case GL_STENCIL_CLEAR_VALUE:		return 1;
    case GL_STENCIL_FAIL:			return 1;
    case GL_STENCIL_FUNC:			return 1;

    case GL_STENCIL_PASS_DEPTH_FAIL:		return 1;
    case GL_STENCIL_PASS_DEPTH_PASS:		return 1;
    case GL_STENCIL_REF:			return 1;
    case GL_STENCIL_TEST:			return 1;

    case GL_STENCIL_VALUE_MASK:			return 1;
    case GL_STENCIL_WRITEMASK:			return 1;
    case GL_STEREO:				return 1;
    case GL_SUBPIXEL_BITS:			return 1;

    case GL_TEXTURE_1D:				return 1;
    case GL_TEXTURE_2D:				return 1;
    /* Blue book lists these without comment, but */
    /* Mesa seems to think they are extentions:   */
    #ifdef GL_TEXTURE_1D_BINDING
    case   GL_TEXTURE_1D_BINDING:		return 1;
    #endif
    #ifdef GL_TEXTURE_2D_BINDING
    case   GL_TEXTURE_2D_BINDING:		return 1;
    #endif

    case GL_TEXTURE_COORD_ARRAY:		return 1;
    case GL_TEXTURE_COORD_ARRAY_SIZE:		return 1;
    case GL_TEXTURE_COORD_ARRAY_STRIDE:		return 1;
    case GL_TEXTURE_COORD_ARRAY_TYPE:		return 1;

    case GL_TEXTURE_GEN_Q:			return 1;
    case GL_TEXTURE_GEN_R:			return 1;
    case GL_TEXTURE_GEN_S:			return 1;
    case GL_TEXTURE_GEN_T:			return 1;

    case GL_TEXTURE_MATRIX:			return 16;
    case GL_TEXTURE_STACK_DEPTH:		return 1;
    case GL_UNPACK_ALIGNMENT:			return 1;
    case GL_UNPACK_LSB_FIRST:			return 1;

    case GL_UNPACK_ROW_LENGTH:			return 1;
    case GL_UNPACK_SKIP_PIXELS:			return 1;
    case GL_UNPACK_SKIP_ROWS:			return 1;
    case GL_UNPACK_SWAP_BYTES:			return 1;

    case GL_VERTEX_ARRAY:			return 1;
    case GL_VERTEX_ARRAY_SIZE:			return 1;
    case GL_VERTEX_ARRAY_STRIDE:		return 1;
    case GL_VERTEX_ARRAY_TYPE:			return 1;

    case GL_VIEWPORT:				return 4;
    case GL_ZOOM_X:				return 1;
    case GL_ZOOM_Y:				return 1;

    default:
	MUQ_WARN("Unknown glGet* pname %d",pname);
	return 0;	/* Just to quiet compilers. */
    }
}

/************************************************************************/
/*-    job_P_Gl_Get_Boolean						*/
/************************************************************************/

void
job_P_Gl_Get_Boolean(
    void
){
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[0] );
	int     vals  = job_get_return_value_count(pname);
	if (vals != 1) MUQ_WARN("glGetBoolean cannot return multiple values");
	{   Vm_Uch buf[16];
	    glGetBooleanv(pname,buf);
	    *jS.s = OBJ_FROM_INT(buf[0]);
	}	
    }    
}
/************************************************************************/
/*-    job_P_Gl_Get_Double						*/
/************************************************************************/

void
job_P_Gl_Get_Double(
    void
){
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[0] );
	int     vals  = job_get_return_value_count(pname);
	if (vals != 1) MUQ_WARN("glGetDouble cannot return multiple values");
	{   Vm_Flt64 buf[16];
	    glGetDoublev(pname,buf);
	    *jS.s = OBJ_FROM_FLOAT(buf[0]);
	}	
    }    
}
/************************************************************************/
/*-    job_P_Gl_Get_Float						*/
/************************************************************************/

void
job_P_Gl_Get_Float(
    void
){
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[0] );
	int     vals  = job_get_return_value_count(pname);
	if (vals != 1) MUQ_WARN("glGetFloat cannot return multiple values");
	{   Vm_Flt32 buf[16];
	    glGetFloatv(pname,buf);
	    *jS.s = OBJ_FROM_FLOAT(buf[0]);
	}	
    }    
}
/************************************************************************/
/*-    job_P_Gl_Get_Integer						*/
/************************************************************************/

void
job_P_Gl_Get_Integer(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[0] );
	int     vals  = job_get_return_value_count(pname);
	if (vals != 1) MUQ_WARN("glGetInteger cannot return multiple values");
	{   Vm_Int32 buf[16];
	    glGetIntegerv(pname,buf);
	    *jS.s = OBJ_FROM_INT(buf[0]);
	}	
    }    
}
/************************************************************************/
/*-    job_P_Gl_Get_Boolean_Block					*/
/************************************************************************/

void
job_P_Gl_Get_Boolean_Block(
    void
){
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[0] );
	int     vals  = job_get_return_value_count(pname);
        job_Guarantee_Headroom( vals+1 );
	if (vals > 16) MUQ_WARN("glGetBoolean cannot return > 16 vals");
	{   Vm_Uch buf[16];
	    int    i;
	    glGetBooleanv(pname,buf);
	    *jS.s = OBJ_BLOCK_START;
	    for (i = 0;   i < vals;   ++i)   *++jS.s = OBJ_FROM_INT(buf[i]);
	    *++jS.s = OBJ_FROM_BLK(vals);
	}	
    }    
}
/************************************************************************/
/*-    job_P_Gl_Get_Double_Block					*/
/************************************************************************/

void
job_P_Gl_Get_Double_Block(
    void
){
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[0] );
	int     vals  = job_get_return_value_count(pname);
        job_Guarantee_Headroom( vals+1 );
	if (vals > 16) MUQ_WARN("glGetDouble cannot return > 16 vals");
	{   Vm_Flt64 buf[16];
	    int    i;
	    glGetDoublev(pname,buf);
	    *jS.s = OBJ_BLOCK_START;
	    for (i = 0;   i < vals;   ++i)   *++jS.s = OBJ_FROM_FLOAT(buf[i]);
	    *++jS.s = OBJ_FROM_BLK(vals);
	}	
    }    
}
/************************************************************************/
/*-    job_P_Gl_Get_Float_Block						*/
/************************************************************************/

void
job_P_Gl_Get_Float_Block(
    void
){
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[0] );
	int     vals  = job_get_return_value_count(pname);
        job_Guarantee_Headroom( vals+1 );
	if (vals > 16) MUQ_WARN("glGetFloat cannot return > 16 vals");
	{   Vm_Flt32 buf[16];
	    int    i;
	    glGetFloatv(pname,buf);
	    *jS.s = OBJ_BLOCK_START;
	    for (i = 0;   i < vals;   ++i)   *++jS.s = OBJ_FROM_FLOAT(buf[i]);
	    *++jS.s = OBJ_FROM_BLK(vals);
	}	
    }    
}
/************************************************************************/
/*-    job_P_Gl_Get_Integer_Block					*/
/************************************************************************/

void
job_P_Gl_Get_Integer_Block(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[0] );
	int     vals  = job_get_return_value_count(pname);
        job_Guarantee_Headroom( vals+1 );
	if (vals > 16) MUQ_WARN("glGetInteger cannot return > 16 vals");
	{   Vm_Int32 buf[16];
	    int    i;
	    glGetIntegerv(pname,buf);
	    *jS.s = OBJ_BLOCK_START;
	    for (i = 0;   i < vals;   ++i)   *++jS.s = OBJ_FROM_INT(buf[i]);
	    *++jS.s = OBJ_FROM_BLK(vals);
	}	
    }    
}
/************************************************************************/
/*-    job_P_Gl_Get_Booleanv						*/
/************************************************************************/

/* These four return a variable number of results in a vector    */
/* We'll need a big case statement to decide which query returns */
/* what number of values.  Should we require an exact match on   */
/* vector length, or just that it be long enough?  Should we     */
/* provide a variation which returns a stackblock instead?       */
void
job_P_Gl_Get_Booleanv(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[-1] );
	int     vals  = job_get_return_value_count(pname);
        job_Guarantee_I08_Len( 0, vals );
	{   Vm_Uch* p = &STG_P(jS.s[0])->byte[0];
	    glGetBooleanv(pname,p);
	    vm_Dirty(jS.s[0]);
	}	
    }    
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Get_Doublev						*/
/************************************************************************/

void
job_P_Gl_Get_Doublev(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[-1] );
	int     vals  = job_get_return_value_count(pname);
        job_Guarantee_F64_Len( 0, vals );
	{   Vm_Flt64* p = &F64_P(jS.s[0])->slot[0];
	    glGetDoublev(pname,p);
	    vm_Dirty(jS.s[0]);
	}	
    }    
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Get_Floatv						*/
/************************************************************************/

void
job_P_Gl_Get_Floatv(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[-1] );
	int     vals  = job_get_return_value_count(pname);
        job_Guarantee_F32_Len( 0, vals );
	{   Vm_Flt32* p = &F32_P(jS.s[0])->slot[0];
	    glGetFloatv(pname,p);
	    vm_Dirty(jS.s[0]);
	}	
    }    
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Get_Integerv						*/
/************************************************************************/

void
job_P_Gl_Get_Integerv(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[-1] );
	int     vals  = job_get_return_value_count(pname);
        job_Guarantee_I32_Len( 0, vals );
	{   Vm_Int32* p = &I32_P(jS.s[0])->slot[0];
	    glGetIntegerv(pname,p);
	    vm_Dirty(jS.s[0]);
	}	
    }    
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Push_Attrib						*/
/************************************************************************/

void
job_P_Gl_Push_Attrib(
    void
){
    GLbitfield u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glPushAttrib(u);
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Pop_Attrib						*/
/************************************************************************/

void
job_P_Gl_Pop_Attrib(
    void
){
    glPopAttrib();
}
/************************************************************************/
/*-    job_P_Gl_Push_Client_Attrib					*/
/************************************************************************/

void
job_P_Gl_Push_Client_Attrib(
    void
){
    GLbitfield u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glPushClientAttrib(u);
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Pop_Client_Attrib					*/
/************************************************************************/

void
job_P_Gl_Pop_Client_Attrib(
    void
){
    glPopClientAttrib();
}
/************************************************************************/
/*-    job_P_Gl_Render_Mode						*/
/************************************************************************/

void
job_P_Gl_Render_Mode(
    void
){
    GLenum u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glRenderMode(u);
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Get_Error						*/
/************************************************************************/

void
job_P_Gl_Get_Error(
    void
){
    GLenum u = glGetError();
    *++jS.s  = OBJ_FROM_INT(u);
}
/************************************************************************/
/*-    job_P_Gl_Get_String						*/
/************************************************************************/

void
job_P_Gl_Get_String(
    void
){
    GLenum u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    {   GLubyte* txt = (GLubyte*)glGetString(u);
        Vm_Obj   stg = txt ? stg_From_Asciz(txt) : OBJ_FROM_BYT0;
	*jS.s        = stg;
    }
}
/************************************************************************/
/*-    job_P_Gl_Finish							*/
/************************************************************************/

void
job_P_Gl_Finish(
    void
){
    glFinish();
}
/************************************************************************/
/*-    job_P_Gl_Flush							*/
/************************************************************************/

void
job_P_Gl_Flush(
    void
){
    glFlush();
}
/************************************************************************/
/*-    job_P_Gl_Hint							*/
/************************************************************************/

void
job_P_Gl_Hint(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum target = OBJ_TO_INT( jS.s[-1] );
        GLenum mode   = OBJ_TO_INT( jS.s[ 0] );
	glHint( target, mode );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Clear_Depth						*/
/************************************************************************/

void
job_P_Gl_Clear_Depth(
    void
){
    job_Guarantee_N_Args(     1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLclampd depth = OBJ_TO_FLOAT( jS.s[0] );
	glClearDepth( depth );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Depth_Func						*/
/************************************************************************/

void
job_P_Gl_Depth_Func(
    void
){
    GLenum u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glDepthFunc(u);
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Depth_Mask						*/
/************************************************************************/

void
job_P_Gl_Depth_Mask(
    void
){
    GLboolean u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glDepthMask(u);
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Depth_Range						*/
/************************************************************************/

void
job_P_Gl_Depth_Range(
    void
){
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLclampd near_val = OBJ_TO_FLOAT( jS.s[-1] );
        GLclampd far_val  = OBJ_TO_FLOAT( jS.s[ 0] );
	glDepthRange( near_val, far_val );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Clear_Accum						*/
/************************************************************************/

void
job_P_Gl_Clear_Accum(
    void
){
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat red   = OBJ_TO_FLOAT( jS.s[-3] );
        GLfloat green = OBJ_TO_FLOAT( jS.s[-2] );
        GLfloat blue  = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat alpha = OBJ_TO_FLOAT( jS.s[ 0] );
	glClearAccum( red, green, blue, alpha );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Accum							*/
/************************************************************************/

void
job_P_Gl_Accum(
    void
){
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Int_Arg(   -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLenum  op    = OBJ_TO_INT(   jS.s[-1] );
        GLfloat value = OBJ_TO_FLOAT( jS.s[ 0] );
	glAccum( op, value );
    }
    jS.s -= 2;
}

/************************************************************************/
/*-    job_P_Gl_Matrix_Mode --						*/
/************************************************************************/

void
job_P_Gl_Matrix_Mode(
    void
) {
    int u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glMatrixMode(u);
    --jS.s;
}

/************************************************************************/
/*-    job_P_Gl_Ortho							*/
/************************************************************************/

void
job_P_Gl_Ortho(
    void
){
    job_Guarantee_N_Args(     6 );
    job_Guarantee_Float_Arg( -5 );
    job_Guarantee_Float_Arg( -4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble left   = OBJ_TO_FLOAT( jS.s[-5] );
        GLdouble right  = OBJ_TO_FLOAT( jS.s[-4] );
        GLdouble bottom = OBJ_TO_FLOAT( jS.s[-3] );
        GLdouble top    = OBJ_TO_FLOAT( jS.s[-2] );
        GLdouble near   = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble far    = OBJ_TO_FLOAT( jS.s[ 0] );
	glOrtho( left, right, bottom, top, near, far );
    }
    jS.s -= 6;
}
/************************************************************************/
/*-    job_P_Gl_Frustum							*/
/************************************************************************/

void
job_P_Gl_Frustum(
    void
){
    job_Guarantee_N_Args(     6 );
    job_Guarantee_Float_Arg( -5 );
    job_Guarantee_Float_Arg( -4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble left   = OBJ_TO_FLOAT( jS.s[-5] );
        GLdouble right  = OBJ_TO_FLOAT( jS.s[-4] );
        GLdouble bottom = OBJ_TO_FLOAT( jS.s[-3] );
        GLdouble top    = OBJ_TO_FLOAT( jS.s[-2] );
        GLdouble near   = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble far    = OBJ_TO_FLOAT( jS.s[ 0] );
	glFrustum( left, right, bottom, top, near, far );
    }
    jS.s -= 6;
}
/************************************************************************/
/*-    job_P_Gl_Viewport						*/
/************************************************************************/

void
job_P_Gl_Viewport(
    void
){
    job_Guarantee_N_Args(   4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLint   x    = OBJ_TO_INT( jS.s[-3] );
        GLint   y    = OBJ_TO_INT( jS.s[-2] );
        GLsizei wide = OBJ_TO_INT( jS.s[-1] );
        GLsizei high = OBJ_TO_INT( jS.s[ 0] );
	glViewport( x, y, wide, high );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Push_Matrix						*/
/************************************************************************/

void
job_P_Gl_Push_Matrix(
    void
){
    glPushMatrix();
}
/************************************************************************/
/*-    job_P_Gl_Pop_Matrix						*/
/************************************************************************/

void
job_P_Gl_Pop_Matrix(
    void
){
    glPopMatrix();
}
/************************************************************************/
/*-    job_P_Gl_Load_Identity						*/
/************************************************************************/

void
job_P_Gl_Load_Identity(
    void
){
    glLoadIdentity();
}
/************************************************************************/
/*-    job_P_Gl_Load_Matrixd						*/
/************************************************************************/

void
job_P_Gl_Load_Matrixd(
    void
){
    job_Guarantee_N_Args(   1 );
    job_Guarantee_F64_Arg(  0 );
    if (f64_Len(jS.s[-1])!=16)MUQ_WARN("glLoadMatrixd needs vector len==16");
    {   GLdouble  mat[16];
        Vm_Flt64* p = &F64_P(jS.s[0])->slot[0];
	int       i;
	for (i = 16;  i --> 0;  )   mat[i] = p[i];
	glLoadMatrixd( mat );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Load_Matrixf						*/
/************************************************************************/

void
job_P_Gl_Load_Matrixf(
    void
){
    job_Guarantee_N_Args(   1 );
    job_Guarantee_F32_Arg(  0 );
    if (f32_Len(jS.s[-1])!=16)MUQ_WARN("glLoadMatrixf needs vector len==16");
    {   GLfloat  mat[16];
        Vm_Flt32* p = &F32_P(jS.s[0])->slot[0];
	int       i;
	for (i = 16;  i --> 0;  )   mat[i] = p[i];
	glLoadMatrixf( mat );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Mult_Matrixd						*/
/************************************************************************/

void
job_P_Gl_Mult_Matrixd(
    void
){
    job_Guarantee_N_Args(   1 );
    job_Guarantee_F64_Arg(  0 );
    if (f64_Len(jS.s[-1])!=16)MUQ_WARN("glMultMatrixd needs vector len==16");
    {   GLdouble  mat[16];
        Vm_Flt64* p = &F64_P(jS.s[0])->slot[0];
	int       i;
	for (i = 16;  i --> 0;  )   mat[i] = p[i];
	glMultMatrixd( mat );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Mult_Matrixf						*/
/************************************************************************/

void
job_P_Gl_Mult_Matrixf(
    void
){
    job_Guarantee_N_Args(   1 );
    job_Guarantee_F32_Arg(  0 );
    if (f32_Len(jS.s[-1])!=16)MUQ_WARN("glMultMatrixf needs vector len==16");
    {   GLfloat  mat[16];
        Vm_Flt32* p = &F32_P(jS.s[0])->slot[0];
	int       i;
	for (i = 16;  i --> 0;  )   mat[i] = p[i];
	glMultMatrixf( mat );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Rotated							*/
/************************************************************************/

void
job_P_Gl_Rotated(
    void
){
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble angle  = OBJ_TO_FLOAT( jS.s[-3] );
        GLdouble x      = OBJ_TO_FLOAT( jS.s[-2] );
        GLdouble y      = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble z      = OBJ_TO_FLOAT( jS.s[ 0] );
	glRotated( angle, x, y, z );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Rotatef							*/
/************************************************************************/

void
job_P_Gl_Rotatef(
    void
){
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat angle  = OBJ_TO_FLOAT( jS.s[-3] );
        GLfloat x      = OBJ_TO_FLOAT( jS.s[-2] );
        GLfloat y      = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat z      = OBJ_TO_FLOAT( jS.s[ 0] );
	glRotatef( angle, x, y, z );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Scaled							*/
/************************************************************************/

void
job_P_Gl_Scaled(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble x      = OBJ_TO_FLOAT( jS.s[-2] );
        GLdouble y      = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble z      = OBJ_TO_FLOAT( jS.s[ 0] );
	glScaled( x, y, z );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Scalef							*/
/************************************************************************/

void
job_P_Gl_Scalef(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat x      = OBJ_TO_FLOAT( jS.s[-2] );
        GLfloat y      = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat z      = OBJ_TO_FLOAT( jS.s[ 0] );
	glScalef( x, y, z );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Translated						*/
/************************************************************************/

void
job_P_Gl_Translated(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble x      = OBJ_TO_FLOAT( jS.s[-2] );
        GLdouble y      = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble z      = OBJ_TO_FLOAT( jS.s[ 0] );
	glTranslated( x, y, z );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Translatef						*/
/************************************************************************/

void
job_P_Gl_Translatef(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat x      = OBJ_TO_FLOAT( jS.s[-2] );
        GLfloat y      = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat z      = OBJ_TO_FLOAT( jS.s[ 0] );
	glTranslatef( x, y, z );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Is_List							*/
/************************************************************************/

void
job_P_Gl_Is_List(
    void
){
    GLuint u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    {   GLboolean result = glIsList(u);
        *jS.s = OBJ_FROM_INT(result);
    }
}
/************************************************************************/
/*-    job_P_Gl_Delete_Lists						*/
/************************************************************************/

void
job_P_Gl_Delete_Lists(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLuint  list  = OBJ_TO_UNT( jS.s[-1] );
        GLsizei range = OBJ_TO_INT( jS.s[ 0] );
	glDeleteLists( list, range );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Gen_Lists						*/
/************************************************************************/

void
job_P_Gl_Gen_Lists(
    void
){
    GLsizei u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    {   GLuint result = glGenLists(u);
        *jS.s = OBJ_FROM_INT(result);
    }
}
/************************************************************************/
/*-    job_P_Gl_New_List						*/
/************************************************************************/

void
job_P_Gl_New_List(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLuint list = OBJ_TO_UNT( jS.s[-1] );
        GLenum mode = OBJ_TO_INT( jS.s[ 0] );
	glNewList( list, mode );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_End_List						*/
/************************************************************************/

void
job_P_Gl_End_List(
    void
){
    glEndList();
}
/************************************************************************/
/*-    job_P_Gl_Call_List						*/
/************************************************************************/

void
job_P_Gl_Call_List(
    void
){
    GLuint u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glCallList(u);
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Call_Lists						*/
/************************************************************************/

void
job_P_Gl_Call_Lists(
    void
){
    MUQ_WARN("job_P_Gl_Call_Lists unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_List_Base						*/
/************************************************************************/

void
job_P_Gl_List_Base(
    void
){
    GLuint u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glListBase(u);
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Begin							*/
/************************************************************************/

void
job_P_Gl_Begin(
    void
){
    GLenum mode = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glBegin(mode);
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_End							*/
/************************************************************************/

void
job_P_Gl_End(
    void
){
    glEnd();
}
/************************************************************************/
/*-    job_P_Gl_Vertex2D						*/
/************************************************************************/

void
job_P_Gl_Vertex2D(
    void
){
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble x      = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble y      = OBJ_TO_FLOAT( jS.s[ 0] );
	glVertex2d( x, y );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Vertex2F						*/
/************************************************************************/

void
job_P_Gl_Vertex2F(
    void
){
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat x      = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat y      = OBJ_TO_FLOAT( jS.s[ 0] );
	glVertex2f( x, y );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Vertex2I						*/
/************************************************************************/

void
job_P_Gl_Vertex2I(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLint x      = OBJ_TO_INT( jS.s[-1] );
        GLint y      = OBJ_TO_INT( jS.s[ 0] );
	glVertex2i( x, y );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Vertex2S						*/
/************************************************************************/

void
job_P_Gl_Vertex2S(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLshort x      = OBJ_TO_INT( jS.s[-1] );
        GLshort y      = OBJ_TO_INT( jS.s[ 0] );
	glVertex2s( x, y );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Vertex3D						*/
/************************************************************************/

void
job_P_Gl_Vertex3D(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble x      = OBJ_TO_FLOAT( jS.s[-2] );
        GLdouble y      = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble z      = OBJ_TO_FLOAT( jS.s[ 0] );
	glVertex3d( x, y, z );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Vertex3F						*/
/************************************************************************/

void
job_P_Gl_Vertex3F(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat x      = OBJ_TO_FLOAT( jS.s[-2] );
        GLfloat y      = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat z      = OBJ_TO_FLOAT( jS.s[ 0] );
	glVertex3f( x, y, z );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Vertex3I						*/
/************************************************************************/

void
job_P_Gl_Vertex3I(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLint x      = OBJ_TO_INT( jS.s[-2] );
        GLint y      = OBJ_TO_INT( jS.s[-1] );
        GLint z      = OBJ_TO_INT( jS.s[ 0] );
	glVertex3i( x, y, z );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Vertex3S						*/
/************************************************************************/

void
job_P_Gl_Vertex3S(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLshort x      = OBJ_TO_INT( jS.s[-2] );
        GLshort y      = OBJ_TO_INT( jS.s[-1] );
        GLshort z      = OBJ_TO_INT( jS.s[ 0] );
	glVertex3s( x, y, z );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Vertex4D						*/
/************************************************************************/

void
job_P_Gl_Vertex4D(
    void
){
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble x      = OBJ_TO_FLOAT( jS.s[-3] );
        GLdouble y      = OBJ_TO_FLOAT( jS.s[-2] );
        GLdouble z      = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble w      = OBJ_TO_FLOAT( jS.s[ 0] );
	glVertex4d( x, y, z, w );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Vertex4F						*/
/************************************************************************/

void
job_P_Gl_Vertex4F(
    void
){
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat x      = OBJ_TO_FLOAT( jS.s[-3] );
        GLfloat y      = OBJ_TO_FLOAT( jS.s[-2] );
        GLfloat z      = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat w      = OBJ_TO_FLOAT( jS.s[ 0] );
	glVertex4f( x, y, z, w );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Vertex4I						*/
/************************************************************************/

void
job_P_Gl_Vertex4I(
    void
){
    job_Guarantee_N_Args(   4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLint x      = OBJ_TO_INT( jS.s[-3] );
        GLint y      = OBJ_TO_INT( jS.s[-2] );
        GLint z      = OBJ_TO_INT( jS.s[-1] );
        GLint w      = OBJ_TO_INT( jS.s[ 0] );
	glVertex4i( x, y, z, w );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Vertex4S						*/
/************************************************************************/

void
job_P_Gl_Vertex4S(
    void
){
    job_Guarantee_N_Args(   4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLshort x      = OBJ_TO_INT( jS.s[-3] );
        GLshort y      = OBJ_TO_INT( jS.s[-2] );
        GLshort z      = OBJ_TO_INT( jS.s[-1] );
        GLshort w      = OBJ_TO_INT( jS.s[ 0] );
	glVertex4s( x, y, z, w );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Vertex2Dv						*/
/************************************************************************/

void
job_P_Gl_Vertex2Dv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F64_Len( 0, 2 );
    glVertex2dv( &F64_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Vertex2Fv						*/
/************************************************************************/

void
job_P_Gl_Vertex2Fv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F32_Len( 0, 2 );
    glVertex2fv( &F32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Vertex2Iv						*/
/************************************************************************/

void
job_P_Gl_Vertex2Iv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I32_Len( 0, 2 );
    glVertex2iv( &I32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Vertex2Sv						*/
/************************************************************************/

void
job_P_Gl_Vertex2Sv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I16_Len( 0, 2 );
    glVertex2sv( &I16_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Vertex3Dv						*/
/************************************************************************/

void
job_P_Gl_Vertex3Dv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F64_Len( 0, 3 );
    glVertex3dv( &F64_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Vertex3Fv						*/
/************************************************************************/

void
job_P_Gl_Vertex3Fv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F32_Len( 0, 3 );
    glVertex3fv( &F32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Vertex3Iv						*/
/************************************************************************/

void
job_P_Gl_Vertex3Iv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I32_Len( 0, 3 );
    glVertex3iv( &I32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Vertex3Sv						*/
/************************************************************************/

void
job_P_Gl_Vertex3Sv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I16_Len( 0, 3 );
    glVertex3sv( &I16_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Vertex4Dv						*/
/************************************************************************/

void
job_P_Gl_Vertex4Dv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F64_Len( 0, 4 );
    glVertex4dv( &F64_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Vertex4Fv						*/
/************************************************************************/

void
job_P_Gl_Vertex4Fv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F32_Len( 0, 4 );
    glVertex4fv( &F32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Vertex4Iv						*/
/************************************************************************/

void
job_P_Gl_Vertex4Iv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I32_Len( 0, 4 );
    glVertex4iv( &I32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Vertex4Sv						*/
/************************************************************************/

void
job_P_Gl_Vertex4Sv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I16_Len( 0, 4 );
    glVertex4sv( &I16_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Normal3B						*/
/************************************************************************/

void
job_P_Gl_Normal3B(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLbyte nx      = OBJ_TO_INT( jS.s[-2] );
        GLbyte ny      = OBJ_TO_INT( jS.s[-1] );
        GLbyte nz      = OBJ_TO_INT( jS.s[ 0] );
	glNormal3b( nx, ny, nz );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Normal3D						*/
/************************************************************************/

void
job_P_Gl_Normal3D(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble nx      = OBJ_TO_FLOAT( jS.s[-2] );
        GLdouble ny      = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble nz      = OBJ_TO_FLOAT( jS.s[ 0] );
	glNormal3d( nx, ny, nz );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Normal3F						*/
/************************************************************************/

void
job_P_Gl_Normal3F(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat nx      = OBJ_TO_FLOAT( jS.s[-2] );
        GLfloat ny      = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat nz      = OBJ_TO_FLOAT( jS.s[ 0] );
	glNormal3f( nx, ny, nz );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Normal3I						*/
/************************************************************************/

void
job_P_Gl_Normal3I(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLint nx      = OBJ_TO_INT( jS.s[-2] );
        GLint ny      = OBJ_TO_INT( jS.s[-1] );
        GLint nz      = OBJ_TO_INT( jS.s[ 0] );
	glNormal3i( nx, ny, nz );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Normal3S						*/
/************************************************************************/

void
job_P_Gl_Normal3S(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLshort nx      = OBJ_TO_INT( jS.s[-2] );
        GLshort ny      = OBJ_TO_INT( jS.s[-1] );
        GLshort nz      = OBJ_TO_INT( jS.s[ 0] );
	glNormal3s( nx, ny, nz );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Normal3Bv						*/
/************************************************************************/

void
job_P_Gl_Normal3Bv(
    void
){
    MUQ_WARN("job_P_Gl_Normal3Bv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Normal3Dv						*/
/************************************************************************/

void
job_P_Gl_Normal3Dv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F64_Len( 0, 3 );
    glNormal3dv( &F64_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Normal3Fv						*/
/************************************************************************/

void
job_P_Gl_Normal3Fv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F32_Len( 0, 3 );
    glNormal3fv( &F32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Normal3Iv						*/
/************************************************************************/

void
job_P_Gl_Normal3Iv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I32_Len( 0, 3 );
    glNormal3iv( &I32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Normal3Sv						*/
/************************************************************************/

void
job_P_Gl_Normal3Sv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I16_Len( 0, 3 );
    glNormal3sv( &I16_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Indexd							*/
/************************************************************************/

void
job_P_Gl_Indexd(
    void
){
    job_Guarantee_N_Args(     1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble c      = OBJ_TO_FLOAT( jS.s[ 0] );
	glIndexd( c );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Indexf							*/
/************************************************************************/

void
job_P_Gl_Indexf(
    void
){
    job_Guarantee_N_Args(     1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat c = OBJ_TO_FLOAT( jS.s[ 0] );
	glIndexf( c );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Indexi							*/
/************************************************************************/

void
job_P_Gl_Indexi(
    void
){
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLint c = OBJ_TO_INT( jS.s[ 0] );
	glIndexi( c );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Indexs							*/
/************************************************************************/

void
job_P_Gl_Indexs(
    void
){
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLshort c = OBJ_TO_INT( jS.s[ 0] );
	glIndexs( c );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Indexub							*/
/************************************************************************/

void
job_P_Gl_Indexub(
    void
){
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLubyte c = OBJ_TO_INT( jS.s[ 0] );
	glIndexub( c );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Indexdv							*/
/************************************************************************/

void
job_P_Gl_Indexdv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F64_Len( 0, 1 );
    glIndexdv( &F64_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Indexfv							*/
/************************************************************************/

void
job_P_Gl_Indexfv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F32_Len( 0, 1 );
    glIndexfv( &F32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Indexiv							*/
/************************************************************************/

void
job_P_Gl_Indexiv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I32_Len( 0, 1 );
    glIndexiv( &I32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Indexsv							*/
/************************************************************************/

void
job_P_Gl_Indexsv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I16_Len( 0, 1 );
    glIndexsv( &I16_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Indexubv						*/
/************************************************************************/

void
job_P_Gl_Indexubv(
    void
){
    MUQ_WARN("job_P_Gl_Indexubv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Color3B							*/
/************************************************************************/

void
job_P_Gl_Color3B(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLbyte red      = OBJ_TO_INT( jS.s[-2] );
        GLbyte green    = OBJ_TO_INT( jS.s[-1] );
        GLbyte blue     = OBJ_TO_INT( jS.s[ 0] );
	glColor3b( red, green, blue );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Color3D							*/
/************************************************************************/

void
job_P_Gl_Color3D(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble red      = OBJ_TO_FLOAT( jS.s[-2] );
        GLdouble green    = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble blue     = OBJ_TO_FLOAT( jS.s[ 0] );
	glColor3d( red, green, blue );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Color3F							*/
/************************************************************************/

void
job_P_Gl_Color3F(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat red      = OBJ_TO_FLOAT( jS.s[-2] );
        GLfloat green    = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat blue     = OBJ_TO_FLOAT( jS.s[ 0] );
	glColor3f( red, green, blue );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Color3I							*/
/************************************************************************/

void
job_P_Gl_Color3I(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLint red      = OBJ_TO_INT( jS.s[-2] );
        GLint green    = OBJ_TO_INT( jS.s[-1] );
        GLint blue     = OBJ_TO_INT( jS.s[ 0] );
	glColor3i( red, green, blue );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Color3S							*/
/************************************************************************/

void
job_P_Gl_Color3S(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLshort red      = OBJ_TO_INT( jS.s[-2] );
        GLshort green    = OBJ_TO_INT( jS.s[-1] );
        GLshort blue     = OBJ_TO_INT( jS.s[ 0] );
	glColor3s( red, green, blue );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Color3Ub						*/
/************************************************************************/

void
job_P_Gl_Color3Ub(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLubyte red      = OBJ_TO_INT( jS.s[-2] );
        GLubyte green    = OBJ_TO_INT( jS.s[-1] );
        GLubyte blue     = OBJ_TO_INT( jS.s[ 0] );
	glColor3ub( red, green, blue );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Color3Ui						*/
/************************************************************************/

void
job_P_Gl_Color3Ui(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLuint red      = OBJ_TO_INT( jS.s[-2] );
        GLuint green    = OBJ_TO_INT( jS.s[-1] );
        GLuint blue     = OBJ_TO_INT( jS.s[ 0] );
	glColor3ui( red, green, blue );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Color3Us						*/
/************************************************************************/

void
job_P_Gl_Color3Us(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLushort red      = OBJ_TO_INT( jS.s[-2] );
        GLushort green    = OBJ_TO_INT( jS.s[-1] );
        GLushort blue     = OBJ_TO_INT( jS.s[ 0] );
	glColor3us( red, green, blue );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Color4B							*/
/************************************************************************/

void
job_P_Gl_Color4B(
    void
){
    job_Guarantee_N_Args(   4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLbyte red      = OBJ_TO_INT( jS.s[-3] );
        GLbyte green    = OBJ_TO_INT( jS.s[-2] );
        GLbyte blue     = OBJ_TO_INT( jS.s[-1] );
        GLbyte alpha    = OBJ_TO_INT( jS.s[ 0] );
	glColor4b( red, green, blue, alpha );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Color4D							*/
/************************************************************************/

void
job_P_Gl_Color4D(
    void
){
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble red      = OBJ_TO_FLOAT( jS.s[-3] );
        GLdouble green    = OBJ_TO_FLOAT( jS.s[-2] );
        GLdouble blue     = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble alpha    = OBJ_TO_FLOAT( jS.s[ 0] );
	glColor4d( red, green, blue, alpha );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Color4F							*/
/************************************************************************/

void
job_P_Gl_Color4F(
    void
){
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat red      = OBJ_TO_FLOAT( jS.s[-3] );
        GLfloat green    = OBJ_TO_FLOAT( jS.s[-2] );
        GLfloat blue     = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat alpha    = OBJ_TO_FLOAT( jS.s[ 0] );
	glColor4f( red, green, blue, alpha );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Color4I							*/
/************************************************************************/

void
job_P_Gl_Color4I(
    void
){
    job_Guarantee_N_Args(   4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLint red      = OBJ_TO_INT( jS.s[-3] );
        GLint green    = OBJ_TO_INT( jS.s[-2] );
        GLint blue     = OBJ_TO_INT( jS.s[-1] );
        GLint alpha    = OBJ_TO_INT( jS.s[ 0] );
	glColor4i( red, green, blue, alpha );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Color4S							*/
/************************************************************************/

void
job_P_Gl_Color4S(
    void
){
    job_Guarantee_N_Args(   4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLshort red      = OBJ_TO_INT( jS.s[-3] );
        GLshort green    = OBJ_TO_INT( jS.s[-2] );
        GLshort blue     = OBJ_TO_INT( jS.s[-1] );
        GLshort alpha    = OBJ_TO_INT( jS.s[ 0] );
	glColor4s( red, green, blue, alpha );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Color4Ub						*/
/************************************************************************/

void
job_P_Gl_Color4Ub(
    void
){
    job_Guarantee_N_Args(   4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLubyte red      = OBJ_TO_INT( jS.s[-3] );
        GLubyte green    = OBJ_TO_INT( jS.s[-2] );
        GLubyte blue     = OBJ_TO_INT( jS.s[-1] );
        GLubyte alpha    = OBJ_TO_INT( jS.s[ 0] );
	glColor4ub( red, green, blue, alpha );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Color4Ui						*/
/************************************************************************/

void
job_P_Gl_Color4Ui(
    void
){
    job_Guarantee_N_Args(   4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLuint red      = OBJ_TO_INT( jS.s[-3] );
        GLuint green    = OBJ_TO_INT( jS.s[-2] );
        GLuint blue     = OBJ_TO_INT( jS.s[-1] );
        GLuint alpha    = OBJ_TO_INT( jS.s[ 0] );
	glColor4ui( red, green, blue, alpha );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Color4Us						*/
/************************************************************************/

void
job_P_Gl_Color4Us(
    void
){
    job_Guarantee_N_Args(   4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLushort red      = OBJ_TO_INT( jS.s[-3] );
        GLushort green    = OBJ_TO_INT( jS.s[-2] );
        GLushort blue     = OBJ_TO_INT( jS.s[-1] );
        GLushort alpha    = OBJ_TO_INT( jS.s[ 0] );
	glColor4us( red, green, blue, alpha );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Color3Bv						*/
/************************************************************************/

void
job_P_Gl_Color3Bv(
    void
){
    MUQ_WARN("job_P_Gl_Color3Bv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Color3Dv						*/
/************************************************************************/

void
job_P_Gl_Color3Dv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F64_Len( 0, 3 );
    glColor3dv( &F64_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Color3Fv						*/
/************************************************************************/

void
job_P_Gl_Color3Fv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F32_Len( 0, 3 );
    glColor3fv( &F32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Color3Iv						*/
/************************************************************************/

void
job_P_Gl_Color3Iv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I32_Len( 0, 3 );
    glColor3iv( &I32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Color3Sv						*/
/************************************************************************/

void
job_P_Gl_Color3Sv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I16_Len( 0, 3 );
    glColor3sv( &I16_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Color3Ubv						*/
/************************************************************************/

void
job_P_Gl_Color3Ubv(
    void
){
    MUQ_WARN("job_P_Gl_Color3Ubv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Color3Uiv						*/
/************************************************************************/

void
job_P_Gl_Color3Uiv(
    void
){
    MUQ_WARN("job_P_Gl_Color3Uiv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Color3Usv						*/
/************************************************************************/

void
job_P_Gl_Color3Usv(
    void
){
    MUQ_WARN("job_P_Gl_Color3Usv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Color4Bv						*/
/************************************************************************/

void
job_P_Gl_Color4Bv(
    void
){
    MUQ_WARN("job_P_Gl_Color4Bv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Color4Dv						*/
/************************************************************************/

void
job_P_Gl_Color4Dv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F64_Len( 0, 4 );
    glColor4dv( &F64_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Color4Fv						*/
/************************************************************************/

void
job_P_Gl_Color4Fv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F32_Len( 0, 4 );
    glColor4fv( &F32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Color4Iv						*/
/************************************************************************/

void
job_P_Gl_Color4Iv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I32_Len( 0, 4 );
    glColor4iv( &I32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Color4Sv						*/
/************************************************************************/

void
job_P_Gl_Color4Sv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I16_Len( 0, 4 );
    glColor4sv( &I16_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Color4Ubv						*/
/************************************************************************/

void
job_P_Gl_Color4Ubv(
    void
){
    MUQ_WARN("job_P_Gl_Color4Ubv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Color4Uiv						*/
/************************************************************************/

void
job_P_Gl_Color4Uiv(
    void
){
    MUQ_WARN("job_P_Gl_Color4Uiv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Color4Usv						*/
/************************************************************************/

void
job_P_Gl_Color4Usv(
    void
){
    MUQ_WARN("job_P_Gl_Color4Usv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord1D						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord1D(
    void
){
    job_Guarantee_N_Args(    1 );
    job_Guarantee_Float_Arg( 0 );
    {   GLdouble s = OBJ_TO_FLOAT( jS.s[ 0] );
	glTexCoord1d( s );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord1F						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord1F(
    void
){
    job_Guarantee_N_Args(    1 );
    job_Guarantee_Float_Arg( 0 );
    {   GLfloat s = OBJ_TO_FLOAT( jS.s[ 0] );
	glTexCoord1f( s );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord1I						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord1I(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    {   GLint s = OBJ_TO_INT( jS.s[ 0] );
	glTexCoord1i( s );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord1S						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord1S(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    {   GLshort s = OBJ_TO_INT( jS.s[ 0] );
	glTexCoord1s( s );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord2D						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord2D(
    void
){
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble s = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble t = OBJ_TO_FLOAT( jS.s[ 0] );
	glTexCoord2d( s, t );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord2F						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord2F(
    void
){
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat s = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat t = OBJ_TO_FLOAT( jS.s[ 0] );
	glTexCoord2f( s, t );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord2I						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord2I(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLint s = OBJ_TO_INT( jS.s[-1] );
        GLint t = OBJ_TO_INT( jS.s[ 0] );
	glTexCoord2i( s, t );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord2S						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord2S(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLshort s = OBJ_TO_INT( jS.s[-1] );
        GLshort t = OBJ_TO_INT( jS.s[ 0] );
	glTexCoord2s( s, t );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord3D						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord3D(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble s = OBJ_TO_FLOAT( jS.s[-2] );
        GLdouble t = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble r = OBJ_TO_FLOAT( jS.s[ 0] );
	glTexCoord3d( s, t, r );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord3F						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord3F(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat s = OBJ_TO_FLOAT( jS.s[-2] );
        GLfloat t = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat r = OBJ_TO_FLOAT( jS.s[ 0] );
	glTexCoord3f( s, t, r );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord3I						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord3I(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLint s = OBJ_TO_INT( jS.s[-2] );
        GLint t = OBJ_TO_INT( jS.s[-1] );
        GLint r = OBJ_TO_INT( jS.s[ 0] );
	glTexCoord3i( s, t, r );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord3S						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord3S(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLshort s = OBJ_TO_INT( jS.s[-2] );
        GLshort t = OBJ_TO_INT( jS.s[-1] );
        GLshort r = OBJ_TO_INT( jS.s[ 0] );
	glTexCoord3s( s, t, r );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord4D						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord4D(
    void
){
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble s = OBJ_TO_FLOAT( jS.s[-3] );
        GLdouble t = OBJ_TO_FLOAT( jS.s[-2] );
        GLdouble r = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble q = OBJ_TO_FLOAT( jS.s[ 0] );
	glTexCoord4d( s, t, r, q );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord4F						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord4F(
    void
){
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat  s = OBJ_TO_FLOAT( jS.s[-3] );
        GLfloat  t = OBJ_TO_FLOAT( jS.s[-2] );
        GLfloat  r = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat  q = OBJ_TO_FLOAT( jS.s[ 0] );
	glTexCoord4f( s, t, r, q );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord4I						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord4I(
    void
){
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLint    s = OBJ_TO_INT( jS.s[-3] );
        GLint    t = OBJ_TO_INT( jS.s[-2] );
        GLint    r = OBJ_TO_INT( jS.s[-1] );
        GLint    q = OBJ_TO_INT( jS.s[ 0] );
	glTexCoord4i( s, t, r, q );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord4S						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord4S(
    void
){
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLshort  s = OBJ_TO_INT( jS.s[-3] );
        GLshort  t = OBJ_TO_INT( jS.s[-2] );
        GLshort  r = OBJ_TO_INT( jS.s[-1] );
        GLshort  q = OBJ_TO_INT( jS.s[ 0] );
	glTexCoord4s( s, t, r, q );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord1Dv						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord1Dv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F64_Len( 0, 1 );
    glTexCoord1dv( &F64_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord1Fv						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord1Fv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F32_Len( 0, 1 );
    glTexCoord1fv( &F32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord1Iv						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord1Iv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I32_Len( 0, 1 );
    glTexCoord1iv( &I32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord1Sv						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord1Sv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I16_Len( 0, 1 );
    glTexCoord1sv( &I16_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord2Dv						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord2Dv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F64_Len( 0, 2 );
    glTexCoord2dv( &F64_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord2Fv						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord2Fv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F32_Len( 0, 2 );
    glTexCoord2fv( &F32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord2Iv						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord2Iv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I32_Len( 0, 2 );
    glTexCoord2iv( &I32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord2Sv						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord2Sv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I16_Len( 0, 2 );
    glTexCoord2sv( &I16_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord3Dv						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord3Dv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F64_Len( 0, 3 );
    glTexCoord3dv( &F64_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord3Fv						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord3Fv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F32_Len( 0, 3 );
    glTexCoord3fv( &F32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord3Iv						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord3Iv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I32_Len( 0, 3 );
    glTexCoord3iv( &I32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord3Sv						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord3Sv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I16_Len( 0, 3 );
    glTexCoord3sv( &I16_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord4Dv						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord4Dv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F64_Len( 0, 4 );
    glTexCoord4dv( &F64_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord4Fv						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord4Fv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F32_Len( 0, 4 );
    glTexCoord4fv( &F32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord4Iv						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord4Iv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I32_Len( 0, 4 );
    glTexCoord4iv( &I32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord4Sv						*/
/************************************************************************/

void
job_P_Gl_Tex_Coord4Sv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I16_Len( 0, 4 );
    glTexCoord4sv( &I16_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos2D						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos2D(
    void
){
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble x = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble y = OBJ_TO_FLOAT( jS.s[ 0] );
	glRasterPos2d( x, y );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos2F						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos2F(
    void
){
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat x = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat y = OBJ_TO_FLOAT( jS.s[ 0] );
	glRasterPos2f( x, y );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos2I						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos2I(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLint x = OBJ_TO_INT( jS.s[-1] );
        GLint y = OBJ_TO_INT( jS.s[ 0] );
	glRasterPos2i( x, y );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos2S						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos2S(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLshort x = OBJ_TO_INT( jS.s[-1] );
        GLshort y = OBJ_TO_INT( jS.s[ 0] );
	glRasterPos2s( x, y );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos3D						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos3D(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble x = OBJ_TO_FLOAT( jS.s[-2] );
        GLdouble y = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble z = OBJ_TO_FLOAT( jS.s[ 0] );
	glRasterPos3d( x, y, z );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos3F						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos3F(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat x = OBJ_TO_FLOAT( jS.s[-2] );
        GLfloat y = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat z = OBJ_TO_FLOAT( jS.s[ 0] );
	glRasterPos3f( x, y, z );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos3I						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos3I(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLint x = OBJ_TO_INT( jS.s[-2] );
        GLint y = OBJ_TO_INT( jS.s[-1] );
        GLint z = OBJ_TO_INT( jS.s[ 0] );
	glRasterPos3i( x, y, z );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos3S						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos3S(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLshort x = OBJ_TO_INT( jS.s[-2] );
        GLshort y = OBJ_TO_INT( jS.s[-1] );
        GLshort z = OBJ_TO_INT( jS.s[ 0] );
	glRasterPos3s( x, y, z );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos4D						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos4D(
    void
){
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble x = OBJ_TO_FLOAT( jS.s[-3] );
        GLdouble y = OBJ_TO_FLOAT( jS.s[-2] );
        GLdouble z = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble w = OBJ_TO_FLOAT( jS.s[ 0] );
	glRasterPos4d( x, y, z, w );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos4F						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos4F(
    void
){
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat x = OBJ_TO_FLOAT( jS.s[-3] );
        GLfloat y = OBJ_TO_FLOAT( jS.s[-2] );
        GLfloat z = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat w = OBJ_TO_FLOAT( jS.s[ 0] );
	glRasterPos4f( x, y, z, w );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos4I						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos4I(
    void
){
    job_Guarantee_N_Args(   4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLint x = OBJ_TO_INT( jS.s[-3] );
        GLint y = OBJ_TO_INT( jS.s[-2] );
        GLint z = OBJ_TO_INT( jS.s[-1] );
        GLint w = OBJ_TO_INT( jS.s[ 0] );
	glRasterPos4i( x, y, z, w );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos4S						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos4S(
    void
){
    job_Guarantee_N_Args(   4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLshort x = OBJ_TO_INT( jS.s[-3] );
        GLshort y = OBJ_TO_INT( jS.s[-2] );
        GLshort z = OBJ_TO_INT( jS.s[-1] );
        GLshort w = OBJ_TO_INT( jS.s[ 0] );
	glRasterPos4s( x, y, z, w );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos2Dv						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos2Dv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F64_Len( 0, 2 );
    glRasterPos2dv( &F64_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos2Fv						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos2Fv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F32_Len( 0, 2 );
    glRasterPos2fv( &F32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos2Iv						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos2Iv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I32_Len( 0, 2 );
    glRasterPos2iv( &I32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos2Sv						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos2Sv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I16_Len( 0, 2 );
    glRasterPos2sv( &I16_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos3Dv						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos3Dv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F64_Len( 0, 3 );
    glRasterPos3dv( &F64_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos3Fv						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos3Fv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F32_Len( 0, 3 );
    glRasterPos3fv( &F32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos3Iv						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos3Iv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I32_Len( 0, 3 );
    glRasterPos3iv( &I32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos3Sv						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos3Sv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I16_Len( 0, 3 );
    glRasterPos3sv( &I16_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos4Dv						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos4Dv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F64_Len( 0, 4 );
    glRasterPos4dv( &F64_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos4Fv						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos4Fv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_F32_Len( 0, 4 );
    glRasterPos4fv( &F32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos4Iv						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos4Iv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I32_Len( 0, 4 );
    glRasterPos4iv( &I32_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Raster_Pos4Sv						*/
/************************************************************************/

void
job_P_Gl_Raster_Pos4Sv(
    void
){
    job_Guarantee_N_Args(  1 );
    job_Guarantee_I16_Len( 0, 4 );
    glRasterPos4sv( &I16_P(jS.s[0])->slot[0] );
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Rectd							*/
/************************************************************************/

void
job_P_Gl_Rectd(
    void
){
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble x1 = OBJ_TO_FLOAT( jS.s[-3] );
        GLdouble y1 = OBJ_TO_FLOAT( jS.s[-2] );
        GLdouble x2 = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble y2 = OBJ_TO_FLOAT( jS.s[ 0] );
	glRectd( x1, y1, x2, y2 );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Rectf							*/
/************************************************************************/

void
job_P_Gl_Rectf(
    void
){
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat x1 = OBJ_TO_FLOAT( jS.s[-3] );
        GLfloat y1 = OBJ_TO_FLOAT( jS.s[-2] );
        GLfloat x2 = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat y2 = OBJ_TO_FLOAT( jS.s[ 0] );
	glRectf( x1, y1, x2, y2 );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Recti							*/
/************************************************************************/

void
job_P_Gl_Recti(
    void
){
    job_Guarantee_N_Args(   4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLint x1 = OBJ_TO_INT( jS.s[-3] );
        GLint y1 = OBJ_TO_INT( jS.s[-2] );
        GLint x2 = OBJ_TO_INT( jS.s[-1] );
        GLint y2 = OBJ_TO_INT( jS.s[ 0] );
	glRecti( x1, y1, x2, y2 );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Rects							*/
/************************************************************************/

void
job_P_Gl_Rects(
    void
){
    job_Guarantee_N_Args(   4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLshort x1 = OBJ_TO_INT( jS.s[-3] );
        GLshort y1 = OBJ_TO_INT( jS.s[-2] );
        GLshort x2 = OBJ_TO_INT( jS.s[-1] );
        GLshort y2 = OBJ_TO_INT( jS.s[ 0] );
	glRects( x1, y1, x2, y2 );
    }
    jS.s -= 4;
}
/************************************************************************/
/*-    job_P_Gl_Rectdv							*/
/************************************************************************/

void
job_P_Gl_Rectdv(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_F64_Len( -1, 2 );
    job_Guarantee_F64_Len(  0, 2 );
    {   F64_P a = NULL;	/* Just to quiet compilers. */
	F64_P b = NULL;	/* Just to quiet compilers. */
	vm_Loc2( (void**)&a, (void**)&b, jS.s[-1], jS.s[0] );
	glRectdv(&a->slot[0],&b->slot[0]);
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Rectfv							*/
/************************************************************************/

void
job_P_Gl_Rectfv(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_F32_Len( -1, 2 );
    job_Guarantee_F32_Len(  0, 2 );
    {   F32_P a = NULL;	/* Just to quiet compilers. */
	F32_P b = NULL;	/* Just to quiet compilers. */
	vm_Loc2( (void**)&a, (void**)&b, jS.s[-1], jS.s[0] );
	glRectfv(&a->slot[0],&b->slot[0]);
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Rectiv							*/
/************************************************************************/

void
job_P_Gl_Rectiv(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_I32_Len( -1, 2 );
    job_Guarantee_I32_Len(  0, 2 );
    {   I32_P a = NULL;	/* Just to quiet compilers. */
	I32_P b = NULL;	/* Just to quiet compilers. */
	vm_Loc2( (void**)&a, (void**)&b, jS.s[-1], jS.s[0] );
	glRectiv(&a->slot[0],&b->slot[0]);
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Rectsv							*/
/************************************************************************/

void
job_P_Gl_Rectsv(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_I16_Len( -1, 2 );
    job_Guarantee_I16_Len(  0, 2 );
    {   I16_P a = NULL;	/* Just to quiet compilers. */
	I16_P b = NULL;	/* Just to quiet compilers. */
	vm_Loc2( (void**)&a, (void**)&b, jS.s[-1], jS.s[0] );
	glRectsv(&a->slot[0],&b->slot[0]);
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Vertex_Pointer						*/
/************************************************************************/

void
job_P_Gl_Vertex_Pointer(
    void
){
    MUQ_WARN("job_P_Gl_Vertex_Pointer unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Normal_Pointer						*/
/************************************************************************/

void
job_P_Gl_Normal_Pointer(
    void
){
    MUQ_WARN("job_P_Gl_Normal_Pointer unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Color_Pointer						*/
/************************************************************************/

void
job_P_Gl_Color_Pointer(
    void
){
    MUQ_WARN("job_P_Gl_Color_Pointer unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Index_Pointer						*/
/************************************************************************/

void
job_P_Gl_Index_Pointer(
    void
){
    MUQ_WARN("job_P_Gl_Index_Pointer unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Tex_Coord_Pointer					*/
/************************************************************************/

void
job_P_Gl_Tex_Coord_Pointer(
    void
){
    MUQ_WARN("job_P_Gl_Tex_Coord_Pointer unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Edge_Flag_Pointer					*/
/************************************************************************/

void
job_P_Gl_Edge_Flag_Pointer(
    void
){
    MUQ_WARN("job_P_Gl_Edge_Flag_Pointer unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Get_Pointerv						*/
/************************************************************************/

void
job_P_Gl_Get_Pointerv(
    void
){
    MUQ_WARN("job_P_Gl_Get_Pointerv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Array_Element						*/
/************************************************************************/

void
job_P_Gl_Array_Element(
    void
){
    MUQ_WARN("job_P_Gl_Array_Element unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Draw_Arrays						*/
/************************************************************************/

void
job_P_Gl_Draw_Arrays(
    void
){
    MUQ_WARN("job_P_Gl_Draw_Arrays unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Draw_Elements						*/
/************************************************************************/

void
job_P_Gl_Draw_Elements(
    void
){
    MUQ_WARN("job_P_Gl_Draw_Elements unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Interleaved_Arrays					*/
/************************************************************************/

void
job_P_Gl_Interleaved_Arrays(
    void
){
    MUQ_WARN("job_P_Gl_Interleaved_Arrays unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Shade_Model						*/
/************************************************************************/

void
job_P_Gl_Shade_Model(
    void
){
    GLenum mode = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glShadeModel(mode);
}
/************************************************************************/
/*-    job_P_Gl_Lightf							*/
/************************************************************************/

void
job_P_Gl_Lightf(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Int_Arg(   -2 );
    job_Guarantee_Int_Arg(   -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLenum  light = OBJ_TO_INT(   jS.s[-2] );
        GLenum  pname = OBJ_TO_INT(   jS.s[-1] );
        GLfloat param = OBJ_TO_FLOAT( jS.s[ 0] );
	glLightf( light, pname, param );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Lighti							*/
/************************************************************************/

void
job_P_Gl_Lighti(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  light = OBJ_TO_INT( jS.s[-2] );
        GLenum  pname = OBJ_TO_INT( jS.s[-1] );
        GLint   param = OBJ_TO_INT( jS.s[ 0] );
	glLighti( light, pname, param );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_light_parameter_count					*/
/************************************************************************/
static int
job_light_parameter_count(
    GLenum pname
) {
    switch (pname) {
    case GL_AMBIENT:				return 4;
    case GL_DIFFUSE:				return 4;
    case GL_SPECULAR:				return 4;
    case GL_POSITION:				return 4;
    case GL_SPOT_DIRECTION:			return 3;
    case GL_SPOT_EXPONENT:			return 1;
    case GL_SPOT_CUTOFF:			return 1;
    case GL_CONSTANT_ATTENUATION:		return 1;
    case GL_LINEAR_ATTENUATION:			return 1;
    case GL_QUADRATIC_ATTENUATION:		return 1;
    default:
	MUQ_WARN("Unknown glLight* pname %d",pname);
	return 0;	/* Just to quiet compilers. */
    }
}

/************************************************************************/
/*-    job_P_Gl_Lightfv							*/
/************************************************************************/

void
job_P_Gl_Lightfv(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    {   GLenum  light = OBJ_TO_INT( jS.s[-2] );
        GLenum  pname = OBJ_TO_INT( jS.s[-1] );
	int     vals  = job_light_parameter_count(pname);
        job_Guarantee_F32_Len(  0, vals );
	glLightfv( light, pname, &F32_P(jS.s[0])->slot[0] );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Lightiv							*/
/************************************************************************/

void
job_P_Gl_Lightiv(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    {   GLenum  light = OBJ_TO_INT( jS.s[-2] );
        GLenum  pname = OBJ_TO_INT( jS.s[-1] );
	int     vals  = job_light_parameter_count(pname);
        job_Guarantee_I32_Len(  0, vals );
	glLightiv( light, pname, &I32_P(jS.s[0])->slot[0] );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Get_Lightfv						*/
/************************************************************************/

void
job_P_Gl_Get_Lightfv(
    void
){
    job_Guarantee_N_Args(    3 );
    job_Guarantee_Int_Arg(  -2 );
    job_Guarantee_Int_Arg(  -1 );
    job_Must_Control_Object( 0 );
    {   GLenum  light = OBJ_TO_INT( jS.s[-2] );
        GLenum  pname = OBJ_TO_INT( jS.s[-1] );
	int     vals  = job_light_parameter_count(pname);
        job_Guarantee_F32_Len(  0, vals );
	glGetLightfv( light, pname, &F32_P(jS.s[0])->slot[0] );
	vm_Dirty( jS.s[0] );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Get_Lightiv						*/
/************************************************************************/

void
job_P_Gl_Get_Lightiv(
    void
){
    job_Guarantee_N_Args(    3 );
    job_Guarantee_Int_Arg(  -2 );
    job_Guarantee_Int_Arg(  -1 );
    job_Must_Control_Object( 0 );
    {   GLenum  light = OBJ_TO_INT( jS.s[-2] );
        GLenum  pname = OBJ_TO_INT( jS.s[-1] );
	int     vals  = job_light_parameter_count(pname);
        job_Guarantee_I32_Len(  0, vals );
	glGetLightiv( light, pname, &I32_P(jS.s[0])->slot[0] );
	vm_Dirty( jS.s[0] );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Light_Modelf						*/
/************************************************************************/

void
job_P_Gl_Light_Modelf(
    void
){
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Int_Arg(   -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLenum  pname = OBJ_TO_INT(   jS.s[-1] );
        GLfloat param = OBJ_TO_FLOAT( jS.s[ 0] );
	glLightModelf(  pname, param );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Light_Modeli						*/
/************************************************************************/

void
job_P_Gl_Light_Modeli(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[-1] );
        GLint   param = OBJ_TO_INT( jS.s[ 0] );
	glLightModeli(  pname, param );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_light_model_parameter_count					*/
/************************************************************************/
static int
job_light_model_parameter_count(
    GLenum pname
) {
    switch (pname) {
    case GL_LIGHT_MODEL_AMBIENT:		return 4;
    case GL_LIGHT_MODEL_LOCAL_VIEWER:		return 1;
    case GL_LIGHT_MODEL_TWO_SIDE:		return 1;
    default:
	MUQ_WARN("Unknown glLightModel* pname %d",pname);
	return 0;	/* Just to quiet compilers. */
    }
}

/************************************************************************/
/*-    job_P_Gl_Light_Modelfv						*/
/************************************************************************/

void
job_P_Gl_Light_Modelfv(
    void
){
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Int_Arg(  -1 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[-1] );
	int     vals  = job_light_model_parameter_count(pname);
        job_Guarantee_F32_Len(  0, vals );
	glLightModelfv( pname, &F32_P(jS.s[0])->slot[0] );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Light_Modeliv						*/
/************************************************************************/

void
job_P_Gl_Light_Modeliv(
    void
){
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Int_Arg(  -1 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[-1] );
	int     vals  = job_light_model_parameter_count(pname);
        job_Guarantee_I32_Len(  0, vals );
	glLightModeliv( pname, &I32_P(jS.s[0])->slot[0] );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Materialf						*/
/************************************************************************/

void
job_P_Gl_Materialf(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Int_Arg(   -2 );
    job_Guarantee_Int_Arg(   -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLenum  face  = OBJ_TO_INT(   jS.s[-2] );
        GLenum  pname = OBJ_TO_INT(   jS.s[-1] );
        GLfloat param = OBJ_TO_FLOAT( jS.s[ 0] );
	glMaterialf( face, pname, param );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Materiali						*/
/************************************************************************/

void
job_P_Gl_Materiali(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  face  = OBJ_TO_INT( jS.s[-2] );
        GLenum  pname = OBJ_TO_INT( jS.s[-1] );
        GLint   param = OBJ_TO_INT( jS.s[ 0] );
	glMateriali( face, pname, param );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_material_parameter_count					*/
/************************************************************************/
static int
job_material_parameter_count(
    GLenum pname
) {
    switch (pname) {
    case GL_AMBIENT:				return 4;
    case GL_DIFFUSE:				return 4;
    case GL_SPECULAR:				return 4;
    case GL_EMISSION:				return 4;
    case GL_SHININESS:				return 1;
    case GL_AMBIENT_AND_DIFFUSE:		return 4;
    case GL_COLOR_INDEXES:			return 3;
    default:
	MUQ_WARN("Unknown glMaterial* pname %d",pname);
	return 0;	/* Just to quiet compilers. */
    }
}

/************************************************************************/
/*-    job_P_Gl_Materialfv						*/
/************************************************************************/

void
job_P_Gl_Materialfv(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    {   GLenum  face  = OBJ_TO_INT( jS.s[-2] );
        GLenum  pname = OBJ_TO_INT( jS.s[-1] );
	int     vals  = job_material_parameter_count(pname);
        job_Guarantee_F32_Len(  0, vals );
	glMaterialfv( face, pname, &F32_P(jS.s[0])->slot[0] );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Materialiv						*/
/************************************************************************/

void
job_P_Gl_Materialiv(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    {   GLenum  face  = OBJ_TO_INT( jS.s[-2] );
        GLenum  pname = OBJ_TO_INT( jS.s[-1] );
	int     vals  = job_material_parameter_count(pname);
        job_Guarantee_I32_Len(  0, vals );
	glMaterialiv( face, pname, &I32_P(jS.s[0])->slot[0] );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Get_Materialfv						*/
/************************************************************************/

void
job_P_Gl_Get_Materialfv(
    void
){
    job_Guarantee_N_Args(    3 );
    job_Guarantee_Int_Arg(  -2 );
    job_Guarantee_Int_Arg(  -1 );
    job_Must_Control_Object( 0 );
    {   GLenum  face  = OBJ_TO_INT( jS.s[-2] );
        GLenum  pname = OBJ_TO_INT( jS.s[-1] );
	int     vals  = job_material_parameter_count(pname);
        job_Guarantee_F32_Len(  0, vals );
	glGetMaterialfv( face, pname, &F32_P(jS.s[0])->slot[0] );
	vm_Dirty( jS.s[0] );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Get_Materialiv						*/
/************************************************************************/

void
job_P_Gl_Get_Materialiv(
    void
){
    job_Guarantee_N_Args(    3 );
    job_Guarantee_Int_Arg(  -2 );
    job_Guarantee_Int_Arg(  -1 );
    job_Must_Control_Object( 0 );
    {   GLenum  face  = OBJ_TO_INT( jS.s[-2] );
        GLenum  pname = OBJ_TO_INT( jS.s[-1] );
	int     vals  = job_material_parameter_count(pname);
        job_Guarantee_I32_Len(  0, vals );
	glGetMaterialiv( face, pname, &I32_P(jS.s[0])->slot[0] );
	vm_Dirty( jS.s[0] );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Color_Material						*/
/************************************************************************/

void
job_P_Gl_Color_Material(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  face = OBJ_TO_INT( jS.s[-1] );
        GLenum  mode = OBJ_TO_INT( jS.s[ 0] );
	glColorMaterial( face, mode );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Pixel_Zoom						*/
/************************************************************************/

void
job_P_Gl_Pixel_Zoom(
    void
){
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat xfactor = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat yfactor = OBJ_TO_FLOAT( jS.s[ 0] );
	glPixelZoom( xfactor, yfactor );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Pixel_Storef						*/
/************************************************************************/

void
job_P_Gl_Pixel_Storef(
    void
){
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Int_Arg(   -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLenum  pname = OBJ_TO_INT(   jS.s[-1] );
        GLfloat param = OBJ_TO_FLOAT( jS.s[ 0] );
	glPixelStoref( pname, param );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Pixel_Storei						*/
/************************************************************************/

void
job_P_Gl_Pixel_Storei(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[-1] );
        GLfloat param = OBJ_TO_INT( jS.s[ 0] );
	glPixelStorei( pname, param );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Pixel_Transferf						*/
/************************************************************************/

void
job_P_Gl_Pixel_Transferf(
    void
){
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Int_Arg(   -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLenum  pname = OBJ_TO_INT(   jS.s[-1] );
        GLfloat param = OBJ_TO_FLOAT( jS.s[ 0] );
	glPixelTransferf( pname, param );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Pixel_Transferi						*/
/************************************************************************/

void
job_P_Gl_Pixel_Transferi(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[-1] );
        GLfloat param = OBJ_TO_INT( jS.s[ 0] );
	glPixelTransferi( pname, param );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Pixel_Mapfv						*/
/************************************************************************/

void
job_P_Gl_Pixel_Mapfv(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    {   GLenum  map     = OBJ_TO_INT( jS.s[-2] );
        GLsizei mapsize = OBJ_TO_INT( jS.s[-1] );
        job_Guarantee_F32_Len( 0, mapsize );
	glPixelMapfv( map, mapsize, &F32_P(jS.s[0])->slot[0] );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Pixel_Mapuiv						*/
/************************************************************************/

void
job_P_Gl_Pixel_Mapuiv(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    {   GLenum  map     = OBJ_TO_INT( jS.s[-2] );
        GLsizei mapsize = OBJ_TO_INT( jS.s[-1] );
        job_Guarantee_I32_Len( 0, mapsize );
	glPixelMapuiv( map, mapsize, &I32_P(jS.s[0])->slot[0] );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Pixel_Mapusv						*/
/************************************************************************/

void
job_P_Gl_Pixel_Mapusv(
    void
){
    MUQ_WARN("job_P_Gl_Pixel_Mapusv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Get_Pixel_Mapfv						*/
/************************************************************************/

void
job_P_Gl_Get_Pixel_Mapfv(
    void
){
    MUQ_WARN("job_P_Gl_Get_Pixel_Mapfv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Get_Pixel_Mapuiv					*/
/************************************************************************/

void
job_P_Gl_Get_Pixel_Mapuiv(
    void
){
    MUQ_WARN("job_P_Gl_Get_Pixel_Mapuiv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Get_Pixel_Mapusv					*/
/************************************************************************/

void
job_P_Gl_Get_Pixel_Mapusv(
    void
){
    MUQ_WARN("job_P_Gl_Get_Pixel_Mapusv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Bitmap							*/
/************************************************************************/

void
job_P_Gl_Bitmap(
    void
){
    MUQ_WARN("job_P_Gl_Bitmap unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Read_Pixels						*/
/************************************************************************/

void
job_P_Gl_Read_Pixels(
    void
){
    MUQ_WARN("job_P_Gl_Read_Pixels unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Draw_Pixels						*/
/************************************************************************/

void
job_P_Gl_Draw_Pixels(
    void
){
    MUQ_WARN("job_P_Gl_Draw_Pixels unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Copy_Pixels						*/
/************************************************************************/

void
job_P_Gl_Copy_Pixels(
    void
){
    job_Guarantee_N_Args(   5 );
    job_Guarantee_Int_Arg( -4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLint   x    = OBJ_TO_INT( jS.s[-4] );
        GLint   y    = OBJ_TO_INT( jS.s[-3] );
        GLsizei wide = OBJ_TO_INT( jS.s[-2] );
        GLsizei high = OBJ_TO_INT( jS.s[-1] );
        GLenum  type = OBJ_TO_INT( jS.s[ 0] );
	glCopyPixels( x, y, wide, high, type );
    }
    jS.s -= 5;
}
/************************************************************************/
/*-    job_P_Gl_Stencil_Func						*/
/************************************************************************/

void
job_P_Gl_Stencil_Func(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  func = OBJ_TO_INT( jS.s[-2] );
        GLint   ref  = OBJ_TO_INT( jS.s[-1] );
        GLuint  mask = OBJ_TO_INT( jS.s[ 0] );
	glStencilFunc( func, ref, mask );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Stencil_Mask						*/
/************************************************************************/

void
job_P_Gl_Stencil_Mask(
    void
){
    GLuint mask = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glStencilMask(mask);
}
/************************************************************************/
/*-    job_P_Gl_Stencil_Op						*/
/************************************************************************/

void
job_P_Gl_Stencil_Op(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  fail  = OBJ_TO_INT( jS.s[-2] );
        GLenum  zfail = OBJ_TO_INT( jS.s[-1] );
        GLenum  zpass = OBJ_TO_INT( jS.s[ 0] );
	glStencilOp( fail, zfail, zpass );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Clear_Stencil						*/
/************************************************************************/

void
job_P_Gl_Clear_Stencil(
    void
){
    GLuint s = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glClearStencil(s);
}
/************************************************************************/
/*-    job_P_Gl_Tex_Gend						*/
/************************************************************************/

void
job_P_Gl_Tex_Gend(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Int_Arg(   -2 );
    job_Guarantee_Int_Arg(   -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLenum   coord = OBJ_TO_INT(   jS.s[-2] );
        GLenum   pname = OBJ_TO_INT(   jS.s[-1] );
        GLdouble param = OBJ_TO_FLOAT( jS.s[ 0] );
	glTexGend( coord, pname, param );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Genf						*/
/************************************************************************/

void
job_P_Gl_Tex_Genf(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Int_Arg(   -2 );
    job_Guarantee_Int_Arg(   -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLenum  coord = OBJ_TO_INT(   jS.s[-2] );
        GLenum  pname = OBJ_TO_INT(   jS.s[-1] );
        GLfloat param = OBJ_TO_FLOAT( jS.s[ 0] );
	glTexGenf( coord, pname, param );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Geni						*/
/************************************************************************/

void
job_P_Gl_Tex_Geni(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  coord = OBJ_TO_INT( jS.s[-2] );
        GLenum  pname = OBJ_TO_INT( jS.s[-1] );
        GLint   param = OBJ_TO_INT( jS.s[ 0] );
	glTexGeni( coord, pname, param );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Gendv						*/
/************************************************************************/

void
job_P_Gl_Tex_Gendv(
    void
){
    MUQ_WARN("job_P_Gl_Tex_Gendv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Tex_Genfv						*/
/************************************************************************/

void
job_P_Gl_Tex_Genfv(
    void
){
    MUQ_WARN("job_P_Gl_Tex_Genfv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Tex_Geniv						*/
/************************************************************************/

void
job_P_Gl_Tex_Geniv(
    void
){
    MUQ_WARN("job_P_Gl_Tex_Geniv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Get_Tex_Gendv						*/
/************************************************************************/

void
job_P_Gl_Get_Tex_Gendv(
    void
){
    MUQ_WARN("job_P_Gl_Get_Tex_Gendv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Get_Tex_Genfv						*/
/************************************************************************/

void
job_P_Gl_Get_Tex_Genfv(
    void
){
    MUQ_WARN("job_P_Gl_Get_Tex_Genfv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Get_Tex_Geniv						*/
/************************************************************************/

void
job_P_Gl_Get_Tex_Geniv(
    void
){
    MUQ_WARN("job_P_Gl_Get_Tex_Geniv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Tex_Envf						*/
/************************************************************************/

void
job_P_Gl_Tex_Envf(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Int_Arg(   -2 );
    job_Guarantee_Int_Arg(   -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLenum  target = OBJ_TO_INT(   jS.s[-2] );
        GLenum  pname  = OBJ_TO_INT(   jS.s[-1] );
        GLfloat param  = OBJ_TO_FLOAT( jS.s[ 0] );
	glTexEnvf( target, pname, param );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Envi						*/
/************************************************************************/

void
job_P_Gl_Tex_Envi(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum target = OBJ_TO_INT( jS.s[-2] );
        GLenum pname  = OBJ_TO_INT( jS.s[-1] );
        GLint  param  = OBJ_TO_INT( jS.s[ 0] );
	glTexEnvi( target, pname, param );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Envfv						*/
/************************************************************************/

void
job_P_Gl_Tex_Envfv(
    void
){
    MUQ_WARN("job_P_Gl_Tex_Envfv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Tex_Enviv						*/
/************************************************************************/

void
job_P_Gl_Tex_Enviv(
    void
){
    MUQ_WARN("job_P_Gl_Tex_Enviv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Get_Tex_Envfv						*/
/************************************************************************/

void
job_P_Gl_Get_Tex_Envfv(
    void
){
    MUQ_WARN("job_P_Gl_Get_Tex_Envfv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Get_Tex_Enviv						*/
/************************************************************************/

void
job_P_Gl_Get_Tex_Enviv(
    void
){
    MUQ_WARN("job_P_Gl_Get_Tex_Enviv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Tex_Parameterf						*/
/************************************************************************/

void
job_P_Gl_Tex_Parameterf(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Int_Arg(   -2 );
    job_Guarantee_Int_Arg(   -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLenum  target = OBJ_TO_INT(   jS.s[-2] );
        GLenum  pname  = OBJ_TO_INT(   jS.s[-1] );
        GLfloat param  = OBJ_TO_FLOAT( jS.s[ 0] );
	glTexParameterf( target, pname, param );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Parameteri						*/
/************************************************************************/

void
job_P_Gl_Tex_Parameteri(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  target = OBJ_TO_INT(   jS.s[-2] );
        GLenum  pname  = OBJ_TO_INT(   jS.s[-1] );
        GLfloat param  = OBJ_TO_FLOAT( jS.s[ 0] );
	glTexParameteri( target, pname, param );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Tex_Parameterfv						*/
/************************************************************************/

void
job_P_Gl_Tex_Parameterfv(
    void
){
    MUQ_WARN("job_P_Gl_Tex_Parameterfv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Tex_Parameteriv						*/
/************************************************************************/

void
job_P_Gl_Tex_Parameteriv(
    void
){
    MUQ_WARN("job_P_Gl_Tex_Parameteriv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Get_Tex_Parameterfv					*/
/************************************************************************/

void
job_P_Gl_Get_Tex_Parameterfv(
    void
){
    MUQ_WARN("job_P_Gl_Get_Tex_Parameterfv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Get_Tex_Parameteriv					*/
/************************************************************************/

void
job_P_Gl_Get_Tex_Parameteriv(
    void
){
    MUQ_WARN("job_P_Gl_Get_Tex_Parameteriv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Get_Tex_Level_Parameterfv				*/
/************************************************************************/

void
job_P_Gl_Get_Tex_Level_Parameterfv(
    void
){
    MUQ_WARN("job_P_Gl_Get_Tex_Level_Parameterfv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Get_Tex_Level_Parameteriv				*/
/************************************************************************/

void
job_P_Gl_Get_Tex_Level_Parameteriv(
    void
){
    MUQ_WARN("job_P_Gl_Get_Tex_Level_Parameteriv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Tex_Image1D						*/
/************************************************************************/

void
job_P_Gl_Tex_Image1D(
    void
){
    MUQ_WARN("job_P_Gl_Tex_Image1D unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Tex_Image2D						*/
/************************************************************************/

void
job_P_Gl_Tex_Image2D(
    void
){
    MUQ_WARN("job_P_Gl_Tex_Image2D unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Get_Tex_Image						*/
/************************************************************************/

void
job_P_Gl_Get_Tex_Image(
    void
){
    MUQ_WARN("job_P_Gl_Get_Tex_Image unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Gen_Textures						*/
/************************************************************************/

void
job_P_Gl_Gen_Textures(
    void
){
    MUQ_WARN("job_P_Gl_Gen_Textures unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Delete_Textures						*/
/************************************************************************/

void
job_P_Gl_Delete_Textures(
    void
){
    MUQ_WARN("job_P_Gl_Delete_Textures unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Bind_Texture						*/
/************************************************************************/

void
job_P_Gl_Bind_Texture(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum target  = OBJ_TO_INT(   jS.s[-1] );
        GLuint texture = OBJ_TO_INT(   jS.s[ 0] );
	glBindTexture( target, texture );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Prioritize_Textures					*/
/************************************************************************/

void
job_P_Gl_Prioritize_Textures(
    void
){
    MUQ_WARN("job_P_Gl_Prioritize_Textures unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Are_Textures_Resident					*/
/************************************************************************/

void
job_P_Gl_Are_Textures_Resident(
    void
){
    MUQ_WARN("job_P_Gl_Are_Textures_Resident unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Is_Texture						*/
/************************************************************************/

void
job_P_Gl_Is_Texture(
    void
){
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLuint    texture = OBJ_TO_INT(   jS.s[ 0] );
	GLboolean result  = glIsTexture( texture );
	*jS.s = OBJ_FROM_INT(result);
    }
}
/************************************************************************/
/*-    job_P_Gl_Tex_Sub_Image1D						*/
/************************************************************************/

void
job_P_Gl_Tex_Sub_Image1D(
    void
){
    MUQ_WARN("job_P_Gl_Tex_Sub_Image1D unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Tex_Sub_Image2D						*/
/************************************************************************/

void
job_P_Gl_Tex_Sub_Image2D(
    void
){
    MUQ_WARN("job_P_Gl_Tex_Sub_Image2D unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Copy_Tex_Image1D					*/
/************************************************************************/

void
job_P_Gl_Copy_Tex_Image1D(
    void
){
    job_Guarantee_N_Args(   7 );
    job_Guarantee_Int_Arg( -6 );
    job_Guarantee_Int_Arg( -5 );
    job_Guarantee_Int_Arg( -4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  target         = OBJ_TO_INT( jS.s[-6] );
        GLint   level          = OBJ_TO_INT( jS.s[-5] );
        GLenum  internalformat = OBJ_TO_INT( jS.s[-4] );
        GLint   x              = OBJ_TO_INT( jS.s[-3] );
        GLint   y              = OBJ_TO_INT( jS.s[-2] );
        GLsizei width          = OBJ_TO_INT( jS.s[-1] );
        GLint   border         = OBJ_TO_INT( jS.s[ 0] );
	glCopyTexImage1D( target, level, internalformat, x, y, width, border );
    }
    jS.s -= 7;
}
/************************************************************************/
/*-    job_P_Gl_Copy_Tex_Image2D					*/
/************************************************************************/

void
job_P_Gl_Copy_Tex_Image2D(
    void
){
    job_Guarantee_N_Args(   8 );
    job_Guarantee_Int_Arg( -7 );
    job_Guarantee_Int_Arg( -6 );
    job_Guarantee_Int_Arg( -5 );
    job_Guarantee_Int_Arg( -4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  target         = OBJ_TO_INT( jS.s[-7] );
        GLint   level          = OBJ_TO_INT( jS.s[-6] );
        GLenum  internalformat = OBJ_TO_INT( jS.s[-5] );
        GLint   x              = OBJ_TO_INT( jS.s[-4] );
        GLint   y              = OBJ_TO_INT( jS.s[-3] );
        GLsizei wide           = OBJ_TO_INT( jS.s[-2] );
        GLsizei high           = OBJ_TO_INT( jS.s[-1] );
        GLint   border         = OBJ_TO_INT( jS.s[ 0] );
	glCopyTexImage2D( target, level, internalformat, x, y, wide, high, border );
    }
    jS.s -= 8;
}
/************************************************************************/
/*-    job_P_Gl_Copy_Tex_Sub_Image1D					*/
/************************************************************************/

void
job_P_Gl_Copy_Tex_Sub_Image1D(
    void
){
    job_Guarantee_N_Args(   6 );
    job_Guarantee_Int_Arg( -5 );
    job_Guarantee_Int_Arg( -4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  target         = OBJ_TO_INT( jS.s[-5] );
        GLint   level          = OBJ_TO_INT( jS.s[-4] );
        GLint   xoffset        = OBJ_TO_INT( jS.s[-3] );
        GLint   x              = OBJ_TO_INT( jS.s[-2] );
        GLint   y              = OBJ_TO_INT( jS.s[-1] );
        GLsizei wide           = OBJ_TO_INT( jS.s[ 0] );
	glCopyTexSubImage1D( target, level, xoffset, x, y, wide );
    }
    jS.s -= 6;
}
/************************************************************************/
/*-    job_P_Gl_Copy_Tex_Sub_Image2D					*/
/************************************************************************/

void
job_P_Gl_Copy_Tex_Sub_Image2D(
    void
){
    job_Guarantee_N_Args(   8 );
    job_Guarantee_Int_Arg( -7 );
    job_Guarantee_Int_Arg( -6 );
    job_Guarantee_Int_Arg( -5 );
    job_Guarantee_Int_Arg( -4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  target  = OBJ_TO_INT( jS.s[-7] );
        GLint   level   = OBJ_TO_INT( jS.s[-6] );
        GLint   xoffset = OBJ_TO_INT( jS.s[-5] );
        GLint   yoffset = OBJ_TO_INT( jS.s[-4] );
        GLint   x       = OBJ_TO_INT( jS.s[-3] );
        GLint   y       = OBJ_TO_INT( jS.s[-2] );
        GLsizei wide    = OBJ_TO_INT( jS.s[-1] );
        GLsizei high    = OBJ_TO_INT( jS.s[ 0] );
	glCopyTexSubImage2D( target, level, xoffset, yoffset, x, y, wide, high );
    }
    jS.s -= 8;
}
/************************************************************************/
/*-    job_P_Gl_Map1D							*/
/************************************************************************/

void
job_P_Gl_Map1D(
    void
){
    MUQ_WARN("job_P_Gl_Map1D unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Map1F							*/
/************************************************************************/

void
job_P_Gl_Map1F(
    void
){
    MUQ_WARN("job_P_Gl_Map1F unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Map2D							*/
/************************************************************************/

void
job_P_Gl_Map2D(
    void
){
    MUQ_WARN("job_P_Gl_Map2D unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Map2F							*/
/************************************************************************/

void
job_P_Gl_Map2F(
    void
){
    MUQ_WARN("job_P_Gl_Map2F unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Get_Mapdv						*/
/************************************************************************/

void
job_P_Gl_Get_Mapdv(
    void
){
    MUQ_WARN("job_P_Gl_Get_Mapdv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Get_Mapfv						*/
/************************************************************************/

void
job_P_Gl_Get_Mapfv(
    void
){
    MUQ_WARN("job_P_Gl_Get_Mapfv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Get_Mapiv						*/
/************************************************************************/

void
job_P_Gl_Get_Mapiv(
    void
){
    MUQ_WARN("job_P_Gl_Get_Mapiv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Eval_Coord1D						*/
/************************************************************************/

void
job_P_Gl_Eval_Coord1D(
    void
){
    job_Guarantee_N_Args(     1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble u  = OBJ_TO_FLOAT( jS.s[ 0] );
	glEvalCoord1d( u );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Eval_Coord1F						*/
/************************************************************************/

void
job_P_Gl_Eval_Coord1F(
    void
){
    job_Guarantee_N_Args(     1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat u  = OBJ_TO_FLOAT( jS.s[ 0] );
	glEvalCoord1f( u );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Eval_Coord1Dv						*/
/************************************************************************/

void
job_P_Gl_Eval_Coord1Dv(
    void
){
    MUQ_WARN("job_P_Gl_Eval_Coord1Dv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Eval_Coord1Fv						*/
/************************************************************************/

void
job_P_Gl_Eval_Coord1Fv(
    void
){
    MUQ_WARN("job_P_Gl_Eval_Coord1Fv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Eval_Coord2D						*/
/************************************************************************/

void
job_P_Gl_Eval_Coord2D(
    void
){
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLdouble u  = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble v  = OBJ_TO_FLOAT( jS.s[ 0] );
	glEvalCoord2d( u, v );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Eval_Coord2D						*/
/************************************************************************/

void
job_P_Gl_Eval_Coord2F(
    void
){
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat u  = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat v  = OBJ_TO_FLOAT( jS.s[ 0] );
	glEvalCoord2f( u, v );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Eval_Coord2Dv						*/
/************************************************************************/

void
job_P_Gl_Eval_Coord2Dv(
    void
){
    MUQ_WARN("job_P_Gl_Eval_Coord2Dv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Eval_Coord2Fv						*/
/************************************************************************/

void
job_P_Gl_Eval_Coord2Fv(
    void
){
    MUQ_WARN("job_P_Gl_Eval_Coord2Fv unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Map_Grid1D						*/
/************************************************************************/

void
job_P_Gl_Map_Grid1D(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Int_Arg(   -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLint    un  = OBJ_TO_FLOAT( jS.s[-2] );
        GLdouble u1  = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble u2  = OBJ_TO_FLOAT( jS.s[ 0] );
	glMapGrid1d( un, u1, u2 );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Map_Grid1F						*/
/************************************************************************/

void
job_P_Gl_Map_Grid1F(
    void
){
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Int_Arg(   -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLint   un  = OBJ_TO_FLOAT( jS.s[-2] );
        GLfloat u1  = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat u2  = OBJ_TO_FLOAT( jS.s[ 0] );
	glMapGrid1f( un, u1, u2 );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Map_Grid2D						*/
/************************************************************************/

void
job_P_Gl_Map_Grid2D(
    void
){
    job_Guarantee_N_Args(     6 );
    job_Guarantee_Int_Arg(   -5 );
    job_Guarantee_Float_Arg( -4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Int_Arg(   -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLint    un  = OBJ_TO_FLOAT( jS.s[-5] );
        GLdouble u1  = OBJ_TO_FLOAT( jS.s[-4] );
        GLdouble u2  = OBJ_TO_FLOAT( jS.s[-3] );
        GLint    vn  = OBJ_TO_FLOAT( jS.s[-2] );
        GLdouble v1  = OBJ_TO_FLOAT( jS.s[-1] );
        GLdouble v2  = OBJ_TO_FLOAT( jS.s[ 0] );
	glMapGrid2d( un, u1, u2, vn, v1, v2 );
    }
    jS.s -= 6;
}
/************************************************************************/
/*-    job_P_Gl_Map_Grid2F						*/
/************************************************************************/

void
job_P_Gl_Map_Grid2F(
    void
){
    job_Guarantee_N_Args(     6 );
    job_Guarantee_Int_Arg(   -5 );
    job_Guarantee_Float_Arg( -4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Int_Arg(   -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLint    un  = OBJ_TO_FLOAT( jS.s[-5] );
        GLfloat  u1  = OBJ_TO_FLOAT( jS.s[-4] );
        GLfloat  u2  = OBJ_TO_FLOAT( jS.s[-3] );
        GLint    vn  = OBJ_TO_FLOAT( jS.s[-2] );
        GLfloat  v1  = OBJ_TO_FLOAT( jS.s[-1] );
        GLfloat  v2  = OBJ_TO_FLOAT( jS.s[ 0] );
	glMapGrid2f( un, u1, u2, vn, v1, v2 );
    }
    jS.s -= 6;
}
/************************************************************************/
/*-    job_P_Gl_Eval_Point1						*/
/************************************************************************/

void
job_P_Gl_Eval_Point1(
    void
){
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLint i = OBJ_TO_INT( jS.s[ 0] );
	glEvalPoint1( i );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Eval_Point2						*/
/************************************************************************/

void
job_P_Gl_Eval_Point2(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLint i = OBJ_TO_INT( jS.s[-1] );
        GLint j = OBJ_TO_INT( jS.s[ 0] );
	glEvalPoint2( i, j );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Eval_Mesh1						*/
/************************************************************************/

void
job_P_Gl_Eval_Mesh1(
    void
){
    job_Guarantee_N_Args(   3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum mode = OBJ_TO_INT( jS.s[-2] );
        GLint  i1   = OBJ_TO_INT( jS.s[-1] );
        GLint  i2   = OBJ_TO_INT( jS.s[ 0] );
	glEvalMesh1( mode, i1, i2 );
    }
    jS.s -= 3;
}
/************************************************************************/
/*-    job_P_Gl_Eval_Mesh2						*/
/************************************************************************/

void
job_P_Gl_Eval_Mesh2(
    void
){
    job_Guarantee_N_Args(   5 );
    job_Guarantee_Int_Arg( -4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum mode = OBJ_TO_INT( jS.s[-4] );
        GLint  i1   = OBJ_TO_INT( jS.s[-3] );
        GLint  i2   = OBJ_TO_INT( jS.s[-2] );
        GLint  j1   = OBJ_TO_INT( jS.s[-1] );
        GLint  j2   = OBJ_TO_INT( jS.s[ 0] );
	glEvalMesh2( mode, i1, i2, j1, j2 );
    }
    jS.s -= 5;
}
/************************************************************************/
/*-    job_P_Gl_Fogf							*/
/************************************************************************/

void
job_P_Gl_Fogf(
    void
){
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Int_Arg(   -1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLenum  pname = OBJ_TO_INT(   jS.s[-1] );
        GLfloat param = OBJ_TO_FLOAT( jS.s[ 0] );
	glFogf( pname, param );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Fogi							*/
/************************************************************************/

void
job_P_Gl_Fogi(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[-1] );
        GLfloat param = OBJ_TO_INT( jS.s[ 0] );
	glFogi( pname, param );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_fog_parameter_count						*/
/************************************************************************/
static int
job_fog_parameter_count(
    GLenum pname
) {
    switch (pname) {
    case GL_FOG_MODE:				return 1;
    case GL_FOG_DENSITY:			return 1;
    case GL_FOG_START:				return 1;
    case GL_FOG_END:				return 1;
    case GL_FOG_INDEX:				return 1;
    case GL_FOG_COLOR:				return 4;
    default:
	MUQ_WARN("Unknown glFog* pname %d",pname);
	return 0;	/* Just to quiet compilers. */
    }
}

/************************************************************************/
/*-    job_P_Gl_Fogfv							*/
/************************************************************************/

void
job_P_Gl_Fogfv(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[-1] );
	int     vals  = job_fog_parameter_count(pname);
        job_Guarantee_F32_Len(  0, vals );
	glFogfv( pname, &F32_P(jS.s[0])->slot[0] );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Fogiv							*/
/************************************************************************/

void
job_P_Gl_Fogiv(
    void
){
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    {   GLenum  pname = OBJ_TO_INT( jS.s[-1] );
	int     vals  = job_fog_parameter_count(pname);
        job_Guarantee_I32_Len(  0, vals );
	glFogiv( pname, &I32_P(jS.s[0])->slot[0] );
    }
    jS.s -= 2;
}
/************************************************************************/
/*-    job_P_Gl_Feedback_Buffer						*/
/************************************************************************/

void
job_P_Gl_Feedback_Buffer(
    void
){
    MUQ_WARN("job_P_Gl_Feedback_Buffer unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Pass_Through						*/
/************************************************************************/

void
job_P_Gl_Pass_Through(
    void
){
    job_Guarantee_N_Args(     1 );
    job_Guarantee_Float_Arg(  0 );
    {   GLfloat token = OBJ_TO_FLOAT( jS.s[ 0] );
	glPassThrough( token );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Select_Buffer						*/
/************************************************************************/

void
job_P_Gl_Select_Buffer(
    void
){
    MUQ_WARN("job_P_Gl_Select_Buffer unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Init_Names						*/
/************************************************************************/

void
job_P_Gl_Init_Names(
    void
){
    glInitNames();
}
/************************************************************************/
/*-    job_P_Gl_Load_Name						*/
/************************************************************************/

void
job_P_Gl_Load_Name(
    void
){
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLuint name = OBJ_TO_INT( jS.s[ 0] );
	glLoadName( name );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Push_Name						*/
/************************************************************************/

void
job_P_Gl_Push_Name(
    void
){
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    {   GLuint name = OBJ_TO_INT( jS.s[ 0] );
	glPushName( name );
    }
    --jS.s;
}
/************************************************************************/
/*-    job_P_Gl_Pop_Name						*/
/************************************************************************/

void
job_P_Gl_Pop_Name(
    void
){
    glPopName();
}
/************************************************************************/
/*-    job_P_Gl_Draw_Range_Elements					*/
/************************************************************************/

void
job_P_Gl_Draw_Range_Elements(
    void
){
    MUQ_WARN("job_P_Gl_Draw_Range_Elements unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Tex_Image3D						*/
/************************************************************************/

void
job_P_Gl_Tex_Image3D(
    void
){
    MUQ_WARN("job_P_Gl_Tex_Image3D unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Tex_Sub_Image3D						*/
/************************************************************************/

void
job_P_Gl_Tex_Sub_Image3D(
    void
){
    MUQ_WARN("job_P_Gl_Tex_Sub_Image3D unimplemented");
}
/************************************************************************/
/*-    job_P_Gl_Copy_Tex_Sub_Image3D					*/
/************************************************************************/

void
job_P_Gl_Copy_Tex_Sub_Image3D(
    void
){
    MUQ_WARN("job_P_Gl_Copy_Tex_Sub_Image3D unimplemented");
}

/************************************************************************/
/*-    job_P_Glut_Init_Display_Mode --					*/
/************************************************************************/

void
job_P_Glut_Init_Display_Mode(
    void
) {
    unsigned int u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );
    glutInitDisplayMode(u);
    --jS.s;
}

/************************************************************************/
/*-    job_P_Glut_Create_Window --					*/
/************************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Glut_Create_Window(
    void
) {
    job_Guarantee_Stg_Arg( 0 );
    {	Vm_Obj stg = jS.s[0];
    	Vm_Int len = stg_Len( stg );
	Vm_Uch buf[ MAX_STRING ];
	job_Guarantee_Headroom( len+2 );
	if (len >= MAX_STRING) MUQ_WARN ("glutCreateWindow arg too long");
	if (len != stg_Get_Bytes( (Vm_Uch*)buf, len, stg, 0 )) {
	    MUQ_WARN ("glutCreateWindow: internal error");
	}
	buf[len] = '\0';	
	{   int win = glutCreateWindow(buf);
	    ogl_register_window_callbacks();
            gluqProcessWindowWorkList();
	    {   Vm_Obj wdw = obj_Alloc( OBJ_CLASS_A_WDW, 0 );
		WDW_P( wdw)->id = OBJ_FROM_INT(win);  vm_Dirty(wdw);
		WDW_P( wdw)->o.objname = stg;         vm_Dirty(wdw);
	        *jS.s = wdw;
		if (win > 0) {
		    Vm_Obj vec = MUQ_P(obj_Muq)->glut_windows;
		    if (OBJ_IS_VEC(vec) && vec_Len(vec) > win) {
		        VEC_P(vec)->slot[win]=wdw; vm_Dirty(vec);
		    }
		}
	    }
	}
    }
}

/************************************************************************/
/*-    job_P_Glut_Init_Display_String					*/
/************************************************************************/

void
job_P_Glut_Init_Display_String(
    void
) {
    job_Guarantee_Stg_Arg( 0 );
    {	Vm_Obj stg = jS.s[0];
    	Vm_Int len = stg_Len( stg );
	Vm_Uch buf[ MAX_STRING ];
	job_Guarantee_Headroom( len+2 );
	if (len >= MAX_STRING) MUQ_WARN ("glutInitDisplayString arg too long");
	if (len != stg_Get_Bytes( (Vm_Uch*)buf, len, stg, 0 )) {
	    MUQ_WARN ("glutInitDisplayString: internal error");
	}
	buf[len] = '\0';	
	glutInitDisplayString(buf);
    }
    --jS.s;
}

/************************************************************************/
/*-    job_P_Glut_Init_Window_Position					*/
/************************************************************************/

void
job_P_Glut_Init_Window_Position(
    void
) {
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   int x = OBJ_TO_INT( jS.s[-1] );
        int y = OBJ_TO_INT( jS.s[ 0] );
	glutInitWindowPosition(x,y);
    }
    jS.s -= 2;
}

/************************************************************************/
/*-    job_P_Glut_Init_Window_Size					*/
/************************************************************************/

void
job_P_Glut_Init_Window_Size(
    void
) {
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   int wide = OBJ_TO_INT( jS.s[-1] );
        int high = OBJ_TO_INT( jS.s[ 0] );
	glutInitWindowSize(wide,high);
    }
    jS.s -= 2;
}

/************************************************************************/
/*-    job_P_Glut_Create_Sub_Window					*/
/************************************************************************/

void
job_P_Glut_Create_Sub_Window(
    void
) {
    job_Guarantee_N_Args(   5 );
    job_Guarantee_Int_Arg( -4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   int win  = OBJ_TO_INT( jS.s[-4] );
        int x    = OBJ_TO_INT( jS.s[-3] );
        int y    = OBJ_TO_INT( jS.s[-2] );
        int wide = OBJ_TO_INT( jS.s[-1] );
        int high = OBJ_TO_INT( jS.s[ 0] );
	win      = glutCreateSubWindow(win,x,y,wide,high);
        ogl_register_window_callbacks();
        gluqProcessWindowWorkList();
        jS.s    -= 4;
	{   Vm_Obj wdw = obj_Alloc( OBJ_CLASS_A_WDW, 0 );
	    WDW_P( wdw)->id = OBJ_FROM_INT(win);  vm_Dirty(wdw);
	    WDW_P( wdw)->o.objname = stg_From_Asciz("subwin"); vm_Dirty(wdw);
	    *jS.s = wdw;
	    if (win > 0) {
		Vm_Obj vec = MUQ_P(obj_Muq)->glut_windows;
		if (OBJ_IS_VEC(vec) && vec_Len(vec) > win) {
		    VEC_P(vec)->slot[win]=wdw; vm_Dirty(vec);
		}
	    }
	    *jS.s = wdw;
	}
    }
}

/************************************************************************/
/*-    job_P_Glut_Destroy_Window					*/
/************************************************************************/

void
job_P_Glut_Destroy_Window(
    void
) {
    int win = job_Guarantee_Wdw_Arg(0);
    glutDestroyWindow(win);
    if (win > 0 && win <= WDW_MAX_ACTIVE_WINDOWS) {
	Vm_Obj vec = MUQ_P(obj_Muq)->glut_windows;
	if (OBJ_IS_VEC(vec) && vec_Len(vec) > win) {
	    VEC_P(vec)->slot[win]=OBJ_NIL; vm_Dirty(vec);
	}
    }
    {   Vm_Obj wdw = *jS.s;
        if (OBJ_IS_OBJ(wdw) && OBJ_IS_CLASS_WDW(wdw)) {
	    WDW_P(wdw)->id = OBJ_FROM_INT(0); vm_Dirty(wdw);
	}
    }
    --jS.s;
}

/************************************************************************/
/*-    Job_P_Glut_Post_Redisplay					*/
/************************************************************************/

void
job_P_Glut_Post_Redisplay(
    void
) {
    glutPostRedisplay();
}

/************************************************************************/
/*-    job_P_Glut_Post_Window_Redisplay					*/
/************************************************************************/

void
job_P_Glut_Post_Window_Redisplay(
    void
) {
    int i = job_Guarantee_Wdw_Arg(0);
    glutPostWindowRedisplay(i);
    --jS.s;
}

/************************************************************************/
/*-    job_P_Glut_Get_Window						*/
/************************************************************************/

void
job_P_Glut_Get_Window(
    void
) {
    Vm_Int win = glutGetWindow();

    if (!win) {
	*++jS.s = OBJ_NIL;
	return;
    }

    if (win > 0 && win <= WDW_MAX_ACTIVE_WINDOWS) {
	Vm_Obj vec = MUQ_P(obj_Muq)->glut_windows;
	if (OBJ_IS_VEC(vec) && vec_Len(vec) > win) {
	    *++jS.s = VEC_P(vec)->slot[win];
	    return;
	}
    }

    *++jS.s = OBJ_FROM_INT(win);
}

/************************************************************************/
/*-    job_P_Glut_Set_Window						*/
/************************************************************************/

void
job_P_Glut_Set_Window(
    void
) {
    int i = job_Guarantee_Wdw_Arg(0);
    if (i != glutGetWindow()) {
	glutSetWindow(i);
        gluqProcessWindowWorkList();
    }
    --jS.s;
}

/************************************************************************/
/*-    job_P_Glut_Set_Window_Title					*/
/************************************************************************/

void
job_P_Glut_Set_Window_Title(
    void
) {
    job_Guarantee_Stg_Arg( 0 );
    {	Vm_Obj stg = jS.s[0];
    	Vm_Int len = stg_Len( stg );
	Vm_Uch buf[ MAX_STRING ];
	job_Guarantee_Headroom( len+2 );
	if (len >= MAX_STRING) MUQ_WARN ("glutInitDisplayString arg too long");
	if (len != stg_Get_Bytes( (Vm_Uch*)buf, len, stg, 0 )) {
	    MUQ_WARN ("glutInitDisplayString: internal error");
	}
	buf[len] = '\0';	
	glutSetWindowTitle(buf);
    }
    --jS.s;
}

/************************************************************************/
/*-    job_P_Glut_Set_Icon_Title					*/
/************************************************************************/

void
job_P_Glut_Set_Icon_Title(
    void
) {
    job_Guarantee_Stg_Arg( 0 );
    {	Vm_Obj stg = jS.s[0];
    	Vm_Int len = stg_Len( stg );
	Vm_Uch buf[ MAX_STRING ];
	job_Guarantee_Headroom( len+2 );
	if (len >= MAX_STRING) MUQ_WARN ("glutInitDisplayString arg too long");
	if (len != stg_Get_Bytes( (Vm_Uch*)buf, len, stg, 0 )) {
	    MUQ_WARN ("glutInitDisplayString: internal error");
	}
	buf[len] = '\0';	
	glutSetIconTitle(buf);
    }
    --jS.s;
}

/************************************************************************/
/*-    job_P_Glut_Position_Window					*/
/************************************************************************/

void
job_P_Glut_Position_Window(
    void
) {
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   int x = OBJ_TO_INT( jS.s[-1] );
        int y = OBJ_TO_INT( jS.s[ 0] );
	glutPositionWindow(x,y);
        gluqProcessWindowWorkList();
    }
    jS.s -= 2;
}

/************************************************************************/
/*-    job_P_Glut_Reshape_Window					*/
/************************************************************************/

void
job_P_Glut_Reshape_Window(
    void
) {
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   int wide = OBJ_TO_INT( jS.s[-1] );
        int high = OBJ_TO_INT( jS.s[ 0] );
	glutReshapeWindow(wide,high);
        gluqProcessWindowWorkList();
    }
    jS.s -= 2;
}

/************************************************************************/
/*-    job_P_Glut_Pop_Window						*/
/************************************************************************/

void
job_P_Glut_Pop_Window(
    void
) {
    glutPopWindow();
    gluqProcessWindowWorkList();
}

/************************************************************************/
/*-    job_P_Glut_Push_Window						*/
/************************************************************************/

void
job_P_Glut_Push_Window(
    void
) {
    glutPushWindow();
    gluqProcessWindowWorkList();
}

/************************************************************************/
/*-    job_P_Glut_Iconify_Window					*/
/************************************************************************/

void
job_P_Glut_Iconify_Window(
    void
) {
    glutIconifyWindow();
}

/************************************************************************/
/*-    job_P_Glut_Show_Window						*/
/************************************************************************/

void
job_P_Glut_Show_Window(
    void
) {
    glutShowWindow();
    gluqProcessWindowWorkList();
}

/************************************************************************/
/*-    job_P_Glut_Hide_Window						*/
/************************************************************************/

void
job_P_Glut_Hide_Window(
    void
) {
    glutHideWindow();
}

/************************************************************************/
/*-    job_P_Glut_Full_Screen						*/
/************************************************************************/

void
job_P_Glut_Full_Screen(
    void
) {
    glutFullScreen();
    gluqProcessWindowWorkList();
}

/************************************************************************/
/*-    job_P_Glut_Set_Cursor						*/
/************************************************************************/

void
job_P_Glut_Set_Cursor(
    void
) {
    int cursor = OBJ_TO_INT( *jS.s );
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    glutSetCursor(cursor);
    gluqProcessWindowWorkList();
    --jS.s;
}

/************************************************************************/
/*-    job_P_Glut_Warp_Pointer						*/
/************************************************************************/

void
job_P_Glut_Warp_Pointer(
    void
) {
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   int x = OBJ_TO_INT( jS.s[-1] );
        int y = OBJ_TO_INT( jS.s[ 0] );
	glutWarpPointer(x,y);
    }
    jS.s -= 2;
}

/************************************************************************/
/*-    job_P_Glut_Establish_Overlay					*/
/************************************************************************/

void
job_P_Glut_Establish_Overlay(
    void
) {
    glutEstablishOverlay();
    gluqProcessWindowWorkList();
}

/************************************************************************/
/*-    job_P_Glut_Remove_Overlay					*/
/************************************************************************/

void
job_P_Glut_Remove_Overlay(
    void
) {
    glutRemoveOverlay();
    gluqProcessWindowWorkList();
}

/************************************************************************/
/*-    job_P_Glut_Use_Layer						*/
/************************************************************************/

void
job_P_Glut_Use_Layer(
    void
) {
    unsigned int u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    glutUseLayer(u);
    gluqProcessWindowWorkList();
    --jS.s;
}

/************************************************************************/
/*-    job_P_Glut_Post_Overlay_Redisplay				*/
/************************************************************************/

void
job_P_Glut_Post_Overlay_Redisplay(
    void
) {
    glutPostOverlayRedisplay();
    gluqProcessWindowWorkList();
}

/************************************************************************/
/*-    job_P_Glut_Window_Overlay_Redisplay				*/
/************************************************************************/

void
job_P_Glut_Window_Overlay_Redisplay(
    void
) {
    int win = job_Guarantee_Wdw_Arg(0);
    glutPostWindowOverlayRedisplay(win);
    gluqProcessWindowWorkList();
    --jS.s;
}

/************************************************************************/
/*-    job_P_Glut_Show_Overlay						*/
/************************************************************************/

void
job_P_Glut_Show_Overlay(
    void
) {
    glutShowOverlay();
    gluqProcessWindowWorkList();
}

/************************************************************************/
/*-    job_P_Glut_Hide_Overlay						*/
/************************************************************************/

void
job_P_Glut_Hide_Overlay(
    void
) {
    glutHideOverlay();
    gluqProcessWindowWorkList();
}

/************************************************************************/
/*-    job_P_Glut_Set_Color						*/
/************************************************************************/

void
job_P_Glut_Set_Color(
    void
) {
    job_Guarantee_N_Args(   4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   int   c     = OBJ_TO_INT(   jS.s[-3] );
        float red   = OBJ_TO_FLOAT( jS.s[-2] );
        float green = OBJ_TO_FLOAT( jS.s[-1] );
        float blue  = OBJ_TO_FLOAT( jS.s[ 0] );
	glutSetColor(c,red,green,blue);
        jS.s    -= 4;
    }
}

/************************************************************************/
/*-    job_P_Glut_Get_Color						*/
/************************************************************************/

void
job_P_Glut_Get_Color(
    void
) {
    job_Guarantee_N_Args(   2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   int   n = OBJ_TO_INT( jS.s[-1] );
        int   c = OBJ_TO_INT( jS.s[ 0] );
	float f = glutGetColor(n,c);
	*--jS.s = OBJ_FROM_FLOAT(f);
    }
}

/************************************************************************/
/*-    job_P_Glut_Copy_Colormap						*/
/************************************************************************/

void
job_P_Glut_Copy_Colormap(
    void
) {
    int win = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    glutCopyColormap(win);
    --jS.s;
}

/************************************************************************/
/*-    job_P_Glut_Get							*/
/************************************************************************/

void
job_P_Glut_Get(
    void
) {
    int typ = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    *jS.s = OBJ_FROM_INT( glutGet(typ) );
}

/************************************************************************/
/*-    job_P_Glut_Device_Get						*/
/************************************************************************/

void
job_P_Glut_Device_Get(
    void
) {
    int typ = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    *jS.s = OBJ_FROM_INT( glutDeviceGet(typ) );
}

/************************************************************************/
/*-    job_P_Glut_Extension_Supported					*/
/************************************************************************/

void
job_P_Glut_Extension_Supported(
    void
) {
    job_Guarantee_Stg_Arg( 0 );
    {	Vm_Obj stg = jS.s[0];
    	Vm_Int len = stg_Len( stg );
	Vm_Uch buf[ MAX_STRING ];
	job_Guarantee_Headroom( len+2 );
	if (len >= MAX_STRING) MUQ_WARN ("glutExtensionSupported arg too long");
	if (len != stg_Get_Bytes( (Vm_Uch*)buf, len, stg, 0 )) {
	    MUQ_WARN ("glutExtensionSupported: internal error");
	}
	buf[len] = '\0';	
	{   int result = glutExtensionSupported(buf);
	    *jS.s = OBJ_FROM_INT(result);
	}
    }
}

/************************************************************************/
/*-    job_P_Glut_Get_Modifiers						*/
/************************************************************************/

void
job_P_Glut_Get_Modifiers(
    void
) {
    int result = glutGetModifiers();
    *++jS.s    = OBJ_FROM_INT(result);
}

/************************************************************************/
/*-    job_P_Glut_Layer_Get						*/
/************************************************************************/

void
job_P_Glut_Layer_Get(
    void
) {
    int typ = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    *jS.s = OBJ_FROM_INT( glutLayerGet(typ) );
}

/************************************************************************/
/*-    job_bitmap_font							*/
/************************************************************************/

#include "../h/Glutbitmap37.h"
static GLUTbitmapFont
job_bitmap_font(
    int font
) {
    switch (font) {
    case 2:   return GLUT_BITMAP_9_BY_15;
    case 3:   return GLUT_BITMAP_8_BY_13;
    case 4:   return GLUT_BITMAP_TIMES_ROMAN_10;
    case 5:   return GLUT_BITMAP_TIMES_ROMAN_24;
    case 6:   return GLUT_BITMAP_HELVETICA_10;
    case 7:   return GLUT_BITMAP_HELVETICA_12;
    case 8:   return GLUT_BITMAP_HELVETICA_18;
    default:
	MUQ_WARN("unsupported bitmap font");
    }
    return GLUT_BITMAP_9_BY_15;	/* Just to quiet compilers. */
}

/************************************************************************/
/*-    job_P_Glut_Bitmap_Character					*/
/************************************************************************/

void
job_P_Glut_Bitmap_Character(
    void
) {
    int font = OBJ_TO_INT( jS.s[-1] );
    int c    = OBJ_TO_INT( jS.s[ 0] );

    job_Guarantee_N_Args(   2 );

    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    
    glutBitmapCharacter( job_bitmap_font(font), c );

    jS.s -= 2;
}

/************************************************************************/
/*-    job_P_Glut_Bitmap_Width						*/
/************************************************************************/

void
job_P_Glut_Bitmap_Width(
    void
) {
    int font = OBJ_TO_INT( jS.s[-1] );
    int c    = OBJ_TO_INT( jS.s[ 0] );

    job_Guarantee_N_Args(   2 );

    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    
    {   Vm_Int result = glutBitmapWidth( job_bitmap_font(font), c );
	*--jS.s = OBJ_FROM_INT(result);
    }
}

/************************************************************************/
/*-    job_P_Glut_Bitmap_Length						*/
/************************************************************************/

#ifndef MAX_STRING
#define MAX_STRING 8192
#endif

void
job_P_Glut_Bitmap_Length(
    void
) {
    int font   = OBJ_TO_INT( jS.s[-1] );
    Vm_Obj txt = OBJ_TO_INT( jS.s[ 0] );

    job_Guarantee_N_Args(   2 );

    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Stg_Arg(  0 );

    {   Vm_Uch buf[ MAX_STRING ];    
        Vm_Int len = stg_Len( txt );
	if (len >= MAX_STRING)MUQ_WARN ("glutBitmapLength: string too big");
	if (len != stg_Get_Bytes( buf , MAX_STRING, txt, 0 )){
	    MUQ_WARN ("glutBitmapLength: internal error");
	}
        buf[len] = '\0';
        {   Vm_Int result = glutBitmapLength( job_bitmap_font(font), buf );
	    *--jS.s = OBJ_FROM_INT(result);
	}
    }
}

/************************************************************************/
/*-    job_stroke_font							*/
/************************************************************************/

#include "../h/Glutstroke37.h"
static GLUTstrokeFont
job_stroke_font(
    int font
) {
    switch (font) {
    case 0:   return GLUT_STROKE_ROMAN;
    case 1:   return GLUT_STROKE_MONO_ROMAN;
    default:
	MUQ_WARN("unsupported stroke font");
    }
    return GLUT_STROKE_ROMAN;	/* Just to quiet compilers. */
}

/************************************************************************/
/*-    job_P_Glut_Stroke_Character					*/
/************************************************************************/

void
job_P_Glut_Stroke_Character(
    void
) {
    int font = OBJ_TO_INT( jS.s[-1] );
    int c    = OBJ_TO_INT( jS.s[ 0] );

    job_Guarantee_N_Args(   2 );

    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    
    glutStrokeCharacter( job_stroke_font(font), c );

    jS.s -= 2;
}

/************************************************************************/
/*-    job_P_Glut_Stroke_Width						*/
/************************************************************************/

void
job_P_Glut_Stroke_Width(
    void
) {
    int font = OBJ_TO_INT( jS.s[-1] );
    int c    = OBJ_TO_INT( jS.s[ 0] );

    job_Guarantee_N_Args(   2 );

    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    
    {   Vm_Int result = glutStrokeWidth( job_stroke_font(font), c );
	*--jS.s = OBJ_FROM_INT(result);
    }
}

/************************************************************************/
/*-    job_P_Glut_Stroke_Length						*/
/************************************************************************/

void
job_P_Glut_Stroke_Length(
    void
) {
    int font   = OBJ_TO_INT( jS.s[-1] );
    Vm_Obj txt = OBJ_TO_INT( jS.s[ 0] );

    job_Guarantee_N_Args(   2 );

    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Stg_Arg(  0 );

    {   Vm_Uch buf[ MAX_STRING ];    
        Vm_Int len = stg_Len( txt );
	if (len >= MAX_STRING)MUQ_WARN ("glutStrokeLength string too big");
	if (len != stg_Get_Bytes( buf , MAX_STRING, txt, 0 )){
	    MUQ_WARN ("glutStrokeLength: internal error");
	}
        buf[len] = '\0';
        {   Vm_Int result = glutStrokeLength( job_stroke_font(font), buf );
	    *--jS.s = OBJ_FROM_INT(result);
	}
    }
}

/************************************************************************/
/*-    job_P_Glut_Wire_Sphere						*/
/************************************************************************/

void
job_P_Glut_Wire_Sphere(
    void
) {
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Int_Arg(   -1 );
    job_Guarantee_Int_Arg(    0 );
    {   double radius = OBJ_TO_FLOAT( jS.s[-2] );
        int    slices = OBJ_TO_INT(   jS.s[-1] );
        int    stacks = OBJ_TO_INT(   jS.s[ 0] );
	glutWireSphere(radius,slices,stacks);
        jS.s    -= 3;
    }
}

/************************************************************************/
/*-    job_P_Glut_Solid_Sphere						*/
/************************************************************************/

void
job_P_Glut_Solid_Sphere(
    void
) {
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Int_Arg(   -1 );
    job_Guarantee_Int_Arg(    0 );
    {   double radius = OBJ_TO_FLOAT( jS.s[-2] );
        int    slices = OBJ_TO_INT(   jS.s[-1] );
        int    stacks = OBJ_TO_INT(   jS.s[ 0] );
	glutSolidSphere(radius,slices,stacks);
        jS.s    -= 3;
    }
}

/************************************************************************/
/*-    job_P_Glut_Wire_Cone						*/
/************************************************************************/

void
job_P_Glut_Wire_Cone(
    void
) {
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Int_Arg(   -1 );
    job_Guarantee_Int_Arg(    0 );
    {   double base   = OBJ_TO_FLOAT( jS.s[-3] );
        double height = OBJ_TO_FLOAT( jS.s[-2] );
        int    slices = OBJ_TO_INT(   jS.s[-1] );
        int    stacks = OBJ_TO_INT(   jS.s[ 0] );
	glutWireCone(base,height,slices,stacks);
        jS.s    -= 4;
    }
}

/************************************************************************/
/*-    job_P_Glut_Solid_Cone						*/
/************************************************************************/

void
job_P_Glut_Solid_Cone(
    void
) {
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Int_Arg(   -1 );
    job_Guarantee_Int_Arg(    0 );
    {   double base   = OBJ_TO_FLOAT( jS.s[-3] );
        double height = OBJ_TO_FLOAT( jS.s[-2] );
        int    slices = OBJ_TO_INT(   jS.s[-1] );
        int    stacks = OBJ_TO_INT(   jS.s[ 0] );
	glutSolidCone(base,height,slices,stacks);
        jS.s    -= 4;
    }
}

/************************************************************************/
/*-    job_P_Glut_Wire_Cube						*/
/************************************************************************/

void
job_P_Glut_Wire_Cube(
    void
) {
    job_Guarantee_N_Args(     1 );
    job_Guarantee_Float_Arg(  0 );
    {   double size   = OBJ_TO_FLOAT( jS.s[0] );
	glutWireCube(size);
    }
    --jS.s;
}

/************************************************************************/
/*-    job_P_Glut_Solid_Cube --						*/
/************************************************************************/

void
job_P_Glut_Solid_Cube(
    void
) {
    job_Guarantee_N_Args(     1 );
    job_Guarantee_Float_Arg(  0 );
    {   double size = OBJ_TO_FLOAT( jS.s[0] );
	glutSolidCube(size);
    }
    --jS.s;
}

/************************************************************************/
/*-    job_P_Glut_Wire_Torus						*/
/************************************************************************/

void
job_P_Glut_Wire_Torus(
    void
) {
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Int_Arg(   -1 );
    job_Guarantee_Int_Arg(    0 );
    {   double innerRadius = OBJ_TO_FLOAT( jS.s[-3] );
        double outerRadius = OBJ_TO_FLOAT( jS.s[-2] );
        int    sides       = OBJ_TO_INT(   jS.s[-1] );
        int    rings       = OBJ_TO_INT(   jS.s[ 0] );
	glutWireTorus(innerRadius,outerRadius,sides,rings);
        jS.s    -= 4;
    }
}

/************************************************************************/
/*-    job_P_Glut_Solid_Torus						*/
/************************************************************************/

void
job_P_Glut_Solid_Torus(
    void
) {
    job_Guarantee_N_Args(     4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Int_Arg(   -1 );
    job_Guarantee_Int_Arg(    0 );
    {   double innerRadius = OBJ_TO_FLOAT( jS.s[-3] );
        double outerRadius = OBJ_TO_FLOAT( jS.s[-2] );
        int    sides       = OBJ_TO_INT(   jS.s[-1] );
        int    rings       = OBJ_TO_INT(   jS.s[ 0] );
	glutSolidTorus(innerRadius,outerRadius,sides,rings);
        jS.s    -= 4;
    }
}

/************************************************************************/
/*-    job_P_Glut_Wire_Dodecahedron					*/
/************************************************************************/

void
job_P_Glut_Wire_Dodecahedron(
    void
) {
    glutWireDodecahedron();
}

/************************************************************************/
/*-    job_P_Glut_Solid_Dodecahedron					*/
/************************************************************************/

void
job_P_Glut_Solid_Dodecahedron(
    void
) {
    glutSolidDodecahedron();
}

/************************************************************************/
/*-    job_P_Glut_Wire_Teapot						*/
/************************************************************************/

void
job_P_Glut_Wire_Teapot(
    void
) {
    job_Guarantee_N_Args(     1 );
    job_Guarantee_Float_Arg(  0 );
    {   double size = OBJ_TO_FLOAT( jS.s[0] );
	glutWireTeapot(size);
    }
    --jS.s;
}

/************************************************************************/
/*-    job_P_Glut_Solid_Teapot						*/
/************************************************************************/

void
job_P_Glut_Solid_Teapot(
    void
) {
    job_Guarantee_N_Args(     1 );
    job_Guarantee_Float_Arg(  0 );
    {   double size = OBJ_TO_FLOAT( jS.s[0] );
	glutSolidTeapot(size);
    }
    --jS.s;
}

/************************************************************************/
/*-    job_P_Glut_Wire_Octahedron					*/
/************************************************************************/

void
job_P_Glut_Wire_Octahedron(
    void
) {
    glutWireOctahedron();
}

/************************************************************************/
/*-    job_P_Glut_Solid_Octahedron					*/
/************************************************************************/

void
job_P_Glut_Solid_Octahedron(
    void
) {
    glutSolidOctahedron();
}

/************************************************************************/
/*-    job_P_Glut_Wire_Tetrahedron					*/
/************************************************************************/

void
job_P_Glut_Wire_Tetrahedron(
    void
) {
    glutWireTetrahedron();
}

/************************************************************************/
/*-    job_P_Glut_Solid_Tetrahedron					*/
/************************************************************************/

void
job_P_Glut_Solid_Tetrahedron(
    void
) {
    glutSolidTetrahedron();
}

/************************************************************************/
/*-    job_P_Glut_Wire_Icosahedron					*/
/************************************************************************/

void
job_P_Glut_Wire_Icosahedron(
    void
) {
    glutWireIcosahedron();
}

/************************************************************************/
/*-    job_P_Glut_Solid_Icosahedron					*/
/************************************************************************/

void
job_P_Glut_Solid_Icosahedron(
    void
) {
    glutSolidIcosahedron();
}

/************************************************************************/
/*-    job_P_Glut_Video_Resize_Get					*/
/************************************************************************/

void
job_P_Glut_Video_Resize_Get(
    void
) {
    int param = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    *jS.s = OBJ_FROM_INT( glutVideoResizeGet(param) );
}

/************************************************************************/
/*-    job_P_Glut_Setup_Video_Resizing					*/
/************************************************************************/

void
job_P_Glut_Setup_Video_Resizing(
    void
) {
    glutSetupVideoResizing();
}

/************************************************************************/
/*-    job_P_Glut_Stop_Video_Resizing					*/
/************************************************************************/

void
job_P_Glut_Stop_Video_Resizing(
    void
) {
    glutStopVideoResizing();
}

/************************************************************************/
/*-    job_P_Glut_Video_Resize						*/
/************************************************************************/

void
job_P_Glut_Video_Resize(
    void
) {
    job_Guarantee_N_Args(   4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   int x    = OBJ_TO_INT( jS.s[-3] );
        int y    = OBJ_TO_INT( jS.s[-2] );
        int wide = OBJ_TO_INT( jS.s[-1] );
        int high = OBJ_TO_INT( jS.s[ 0] );
	glutVideoResize(x,y,wide,high);
        jS.s    -= 4;
    }
}

/************************************************************************/
/*-    job_P_Glut_Video_Pan						*/
/************************************************************************/

void
job_P_Glut_Video_Pan(
    void
) {
    job_Guarantee_N_Args(   4 );
    job_Guarantee_Int_Arg( -3 );
    job_Guarantee_Int_Arg( -2 );
    job_Guarantee_Int_Arg( -1 );
    job_Guarantee_Int_Arg(  0 );
    {   int x    = OBJ_TO_INT( jS.s[-3] );
        int y    = OBJ_TO_INT( jS.s[-2] );
        int wide = OBJ_TO_INT( jS.s[-1] );
        int high = OBJ_TO_INT( jS.s[ 0] );
	glutVideoPan(x,y,wide,high);
        jS.s    -= 4;
    }
}

/************************************************************************/
/*-    job_P_Glut_Ignore_Key_Repeat					*/
/************************************************************************/

void
job_P_Glut_Ignore_Key_Repeat(
    void
) {
    int ignore = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    glutIgnoreKeyRepeat(ignore);
    --jS.s;
}

/************************************************************************/
/*-    job_P_Glut_Set_Key_Repeat					*/
/************************************************************************/

void
job_P_Glut_Set_Key_Repeat(
    void
) {
    int repeatMode = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    glutSetKeyRepeat(repeatMode);
    --jS.s;
}

/************************************************************************/
/*-    job_P_Glut_Game_Mode_String					*/
/************************************************************************/

void
job_P_Glut_Game_Mode_String(
    void
) {
    job_Guarantee_Stg_Arg( 0 );
    {	Vm_Obj stg = jS.s[0];
    	Vm_Int len = stg_Len( stg );
	Vm_Uch buf[ MAX_STRING ];
	job_Guarantee_Headroom( len+2 );
	if (len >= MAX_STRING) MUQ_WARN ("glutExtensionSupported arg too long");
	if (len != stg_Get_Bytes( (Vm_Uch*)buf, len, stg, 0 )) {
	    MUQ_WARN ("glutExtensionSupported: internal error");
	}
	buf[len] = '\0';	
	glutGameModeString(buf);
    }
}

/************************************************************************/
/*-    job_P_Glut_Enter_Game_Mode					*/
/************************************************************************/

void
job_P_Glut_Enter_Game_Mode(
    void
) {
    int result = glutEnterGameMode();
    *++jS.s    = OBJ_FROM_INT(result);
}

/************************************************************************/
/*-    job_P_Glut_Leave_Game_Mode					*/
/************************************************************************/

void
job_P_Glut_Leave_Game_Mode(
    void
) {
    glutLeaveGameMode();
}

/************************************************************************/
/*-    job_P_Glut_Game_Mode_Get						*/
/************************************************************************/

void
job_P_Glut_Game_Mode_Get(
    void
) {
    int mode = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(   1 );
    job_Guarantee_Int_Arg(  0 );
    *jS.s = OBJ_FROM_INT( glutGameModeGet(mode) );
}

/************************************************************************/
/*-    job_P_Gluq_Events_Pending					*/
/************************************************************************/

void
job_P_Gluq_Events_Pending(
    void
) {
    if (eventQcat != eventQrat) {
        *++jS.s = OBJ_T;
        return;
    }

    if (XPending(__glutDisplay)) {
	processEventsAndTimeouts();
    }

    *++jS.s = OBJ_FROM_BOOL( eventQcat != eventQrat );
}

/************************************************************************/
/*-    job_P_Gluq_Event							*/
/************************************************************************/

static void
job_gluq_event(
    struct openGLevent* e
) {
    Vm_Obj wdw = OBJ_NIL;
    Vm_Int win = e->window;

    if (win > 0 && win <= WDW_MAX_ACTIVE_WINDOWS) {
	Vm_Obj vec = MUQ_P(obj_Muq)->glut_windows;
	if (OBJ_IS_VEC(vec) && vec_Len(vec) > win) {
	    wdw = VEC_P(vec)->slot[win];
	}
    }

    switch (e->opcode) {

    case GT_DISPLAY:
	*++jS.s = OBJ_BLOCK_START  ;
	*++jS.s = stg_From_Asciz("Display");
	*++jS.s = wdw;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_FROM_BLK( 7 );
	return;

    case GT_RESHAPE:
	*++jS.s = OBJ_BLOCK_START  ;
	*++jS.s = stg_From_Asciz("Reshape");
	*++jS.s = wdw;
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->x);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->y);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->state); /* locx */
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->button);/* locy */
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_FROM_BLK( 7 );
	return;

    case GT_KEY:
	*++jS.s = OBJ_BLOCK_START  ;
	*++jS.s = stg_From_Asciz("Key");
	*++jS.s = wdw;
	*++jS.s = OBJ_FROM_CHAR((Vm_Int)e->state);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->x);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->y);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->mask);
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_FROM_BLK( 7 );
	return;

    case GT_KEY_UP:
	*++jS.s = OBJ_BLOCK_START  ;
	*++jS.s = stg_From_Asciz("KeyUp");
	*++jS.s = wdw;
	*++jS.s = OBJ_FROM_CHAR((Vm_Int)e->state);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->x);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->y);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->mask);
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_FROM_BLK( 7 );
	return;

    case GT_MOUSE:
	*++jS.s = OBJ_BLOCK_START  ;
	*++jS.s = stg_From_Asciz("Mouse");
	*++jS.s = wdw;
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->state);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->button);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->x);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->y);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->mask);
	*++jS.s = OBJ_FROM_BLK( 7 );
	return;

    case GT_MOTION:
	*++jS.s = OBJ_BLOCK_START  ;
	*++jS.s = stg_From_Asciz("Motion");
	*++jS.s = wdw;
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->x);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->y);
	*++jS.s = OBJ_NIL;
        *++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_FROM_BLK( 7 );
	return;

    case GT_PASSIVE:
	*++jS.s = OBJ_BLOCK_START  ;
	*++jS.s = stg_From_Asciz("Passive");
	*++jS.s = wdw;
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->x);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->y);
	*++jS.s = OBJ_NIL;
        *++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_FROM_BLK( 7 );
	return;

    case GT_SPECIAL:
	*++jS.s = OBJ_BLOCK_START  ;
	*++jS.s = stg_From_Asciz("FnKey");
	*++jS.s = wdw;
	*++jS.s = OBJ_FROM_CHAR((Vm_Int)e->state);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->x);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->y);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->mask);
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_FROM_BLK( 7 );
	return;

    case GT_SPECIAL_UP:
	*++jS.s = OBJ_BLOCK_START  ;
	*++jS.s = stg_From_Asciz("FnKeyUp");
	*++jS.s = wdw;
	*++jS.s = OBJ_FROM_CHAR((Vm_Int)e->state);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->x);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->y);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->mask);
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_FROM_BLK( 7 );
	return;

    case GT_ENTRY:
	*++jS.s = OBJ_BLOCK_START  ;
	*++jS.s = stg_From_Asciz("Entry");
	*++jS.s = wdw;
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->state);
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_FROM_BLK( 7 );
	return;

    case GT_STATUS:
	*++jS.s = OBJ_BLOCK_START  ;
	*++jS.s = stg_From_Asciz("Status");
	*++jS.s = wdw;
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->state);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->x);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->y);
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_FROM_BLK( 7 );
	return;

    case GT_VISIBLE:
	*++jS.s = OBJ_BLOCK_START  ;
	*++jS.s = stg_From_Asciz("Visible");
	*++jS.s = wdw;
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->state);
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_FROM_BLK( 7 );
	return;

    case GT_BUTTONS:
	*++jS.s = OBJ_BLOCK_START  ;
	*++jS.s = stg_From_Asciz("Buttons");
	*++jS.s = wdw;
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->button);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->state);
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_FROM_BLK( 7 );
	return;

    case GT_DIALS:
	*++jS.s = OBJ_BLOCK_START  ;
	*++jS.s = stg_From_Asciz("Dials");
	*++jS.s = wdw;
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->button);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->x);
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_FROM_BLK( 7 );
	return;

    case GT_PADXY:
	*++jS.s = OBJ_BLOCK_START  ;
	*++jS.s = stg_From_Asciz("PadXY");
	*++jS.s = wdw;
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->x);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->y);
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_FROM_BLK( 7 );
	return;

    case GT_PADKEY:
	*++jS.s = OBJ_BLOCK_START  ;
	*++jS.s = stg_From_Asciz("PadKey");
	*++jS.s = wdw;
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->button);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->state);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->x);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->y);
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_FROM_BLK( 7 );
	return;

    case GT_BALLXYZ:
	*++jS.s = OBJ_BLOCK_START  ;
	*++jS.s = stg_From_Asciz("BallXYZ");
	*++jS.s = wdw;
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->x);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->y);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->state);
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_FROM_BLK( 7 );
	return;

    case GT_BALLROT:
	*++jS.s = OBJ_BLOCK_START  ;
	*++jS.s = stg_From_Asciz("BallRot");
	*++jS.s = wdw;
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->x);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->y);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->state);
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_FROM_BLK( 7 );
	return;

    case GT_BALLKEY:
	*++jS.s = OBJ_BLOCK_START  ;
	*++jS.s = stg_From_Asciz("BallKey");
	*++jS.s = wdw;
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->button);
	*++jS.s = OBJ_FROM_INT((Vm_Int)e->state);
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_NIL;
	*++jS.s = OBJ_FROM_BLK( 7 );
	return;

    default:
	/* This should be impossible: */
	MUQ_WARN("glutEvent: internal err");
    }
}

void
job_P_Gluq_Event(
    void
) {
    struct openGLevent e;

    /* To humor languages uncomfortable with variable  */
    /* numbers of return values, we return same number */
    /* of values for  all events, by padding with      */
    /* trailing NILs:                                  */
    job_Guarantee_Headroom( 9 );

    /* If we have events stored in our internal */
    /* queue, just return the next one from it: */
    if (ogl_GetEvent( &e )) {
        job_gluq_event( &e );
	return;
    }

    /* Do work required on windows.  In         */
    /* particular, they may need to be mapped   */
    /* if we just started up, else we will get  */
    /* no events.  The logic here is blindly    */
    /* copied from Mark's glutMainLoop() code   */
    /* -- some aspects of it mystify me, such   */
    /* as why 'remainder' is placed back at the */
    /* head of the queue, instead of the tail:  */
    gluqProcessWindowWorkList();

    /* Check the X queue and propagate events   */
    /* from it into our internal app queue:     */
    {   int i = XPending(__glutDisplay);
	if (i)  processEventsAndTimeouts();
    }

    /* Check our internal app event queue again */
    /* to see if the above reloaded it:         */
    if (ogl_GetEvent( &e )) {
        job_gluq_event( &e );
	return;
    }

    /* No events available for processing:      */
    *++jS.s = OBJ_BLOCK_START  ;
    *++jS.s = OBJ_NIL;
    *++jS.s = OBJ_NIL;
    *++jS.s = OBJ_NIL;
    *++jS.s = OBJ_NIL;
    *++jS.s = OBJ_NIL;
    *++jS.s = OBJ_NIL;
    *++jS.s = OBJ_NIL;
    *++jS.s = OBJ_FROM_BLK( 7 );
}

/************************************************************************/
/*-    job_P_Gluq_Queue_Event						*/
/************************************************************************/

void
job_P_Gluq_Queue_Event(
    void
) {
    MUQ_WARN("gluqQueueEvent unimplemented");
}

/************************************************************************/
/*-    job_P_Gluq_Mouse_Position					*/
/************************************************************************/

void
job_P_Gluq_Mouse_Position(
    void
) {
    job_Guarantee_Headroom( 4 );
    
    *++jS.s = OBJ_BLOCK_START  ;
    *++jS.s = OBJ_FROM_INT( ogl_mouse_x );
    *++jS.s = OBJ_FROM_INT( ogl_mouse_y );
    *++jS.s = OBJ_FROM_BLK( 2 );
}

/************************************************************************/
/*-    job_P_Gluq_Draw_Terrain						*/
/************************************************************************/

void
job_P_Gluq_Draw_Terrain(
    void
) {
    MUQ_WARN("gluqDrawTerrain unimplemented");
}

/************************************************************************/
/*-    job_P_Gluq_Draw_Face						*/
/************************************************************************/

void
job_P_Gluq_Draw_Face(
    void
) {
    /* The six basic expressions: */
    /* * sadness                  */
    /* * anger                    */
    /* * joy                      */
    /* * fear                     */
    /* * disgust                  */
    /* * surprise                 */
#ifdef SOON
    Vm_Obj parameter = job_Get_Val_Block( (Vm_Obj) deflt, (Vm_Int) size );
#endif

    /* Get size of block, verify stack holds that much: */
#ifdef SOON
    Vm_Int size = OBJ_TO_BLK( jS.s[ 0] );
    job_Guarantee_N_Args(           2  );
    job_Guarantee_Blk_Arg(          0  );
    job_Guarantee_N_Args( size+2 );

    /* Pop arguments off stack: */
    jS.s -= size+2;
#endif

    /* Draw main box, with bilateral symmetry: */
    glBegin(GL_TRIANGLES);

    /* viewer's left                   */    /* viewer's right                  */
    glVertex3f( -0.100,  1.000,  0.000 );    glVertex3f(  0.100,  1.000,  0.000 );
    glVertex3f( -0.666,  1.000,  0.000 );    glVertex3f(  0.666, -0.333,  0.000 );
    glVertex3f( -0.666, -0.333,  0.000 );    glVertex3f(  0.666,  1.000,  0.000 );

    glVertex3f( -0.100,  1.000,  0.000 );    glVertex3f(  0.100,  1.000,  0.000 );
    glVertex3f( -0.666, -0.333,  0.000 );    glVertex3f(  0.100, -0.333,  0.000 );
    glVertex3f(  0.100, -0.333,  0.000 );    glVertex3f(  0.666, -0.333,  0.000 );

    glEnd();
}

/************************************************************************/
/*-    job_P_Gluq_Draw_Biped						*/
/************************************************************************/

void
job_P_Gluq_Draw_Biped(
    void
) {
    MUQ_WARN("gluqDrawBiped unimplemented");
}

/************************************************************************/
/*-    job_P_Gluq_Draw_Quadruped					*/
/************************************************************************/

void
job_P_Gluq_Draw_Quadruped(
    void
) {
    MUQ_WARN("gluqDrawBiped unimplemented");
}

/************************************************************************/
/*-    job_avatar_enable_ok						*/
/************************************************************************/

static int
job_avatar_enable_ok(
    int u
) {
    switch (u) {
    case GL_AUTO_NORMAL:                         return TRUE;
    case GL_BLEND:                               return TRUE;
    case GL_COLOR_MATERIAL:                      return TRUE;
    case GL_CULL_FACE:                           return TRUE;
    case GL_LINE_SMOOTH:                         return TRUE;
    case GL_LINE_STIPPLE:                        return TRUE;
    case GL_MAP1_COLOR_4:                        return TRUE;
    case GL_MAP1_NORMAL:                         return TRUE;
    case GL_MAP1_TEXTURE_COORD_1:                return TRUE;
    case GL_MAP1_TEXTURE_COORD_2:                return TRUE;
    case GL_MAP1_TEXTURE_COORD_3:                return TRUE;
    case GL_MAP1_TEXTURE_COORD_4:                return TRUE;
    case GL_MAP1_VERTEX_3:                       return TRUE;
    case GL_MAP1_VERTEX_4:                       return TRUE;
    case GL_MAP2_COLOR_4:                        return TRUE;
    case GL_MAP2_NORMAL:                         return TRUE;
    case GL_MAP2_TEXTURE_COORD_1:                return TRUE;
    case GL_MAP2_TEXTURE_COORD_2:                return TRUE;
    case GL_MAP2_TEXTURE_COORD_3:                return TRUE;
    case GL_MAP2_TEXTURE_COORD_4:                return TRUE;
    case GL_MAP2_VERTEX_3:                       return TRUE;
    case GL_MAP2_VERTEX_4:                       return TRUE;
    case GL_NORMALIZE:                           return TRUE;
    case GL_POINT_SMOOTH:                        return TRUE;
    case GL_POLYGON_OFFSET_FILL:                 return TRUE;
    case GL_POLYGON_OFFSET_LINE:                 return TRUE;
    case GL_POLYGON_OFFSET_POINT:                return TRUE;
    case GL_POLYGON_SMOOTH:                      return TRUE;
    case GL_POLYGON_STIPPLE:                     return TRUE;
    case GL_SCISSOR_TEST:                        return TRUE;
    case GL_TEXTURE_1D:                          return TRUE;
    case GL_TEXTURE_2D:                          return TRUE;
    case GL_TEXTURE_GEN_Q:                       return TRUE;
    case GL_TEXTURE_GEN_R:                       return TRUE;
    case GL_TEXTURE_GEN_S:                       return TRUE;
    case GL_TEXTURE_GEN_T:                       return TRUE;
    }
    return FALSE;
}


/************************************************************************/
/*-    job_P_Gla_Enable	-- avatar version of glEnable			*/
/************************************************************************/

void
job_P_Gla_Enable(
    void
) {
    int u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );

    /* glEnable is a functionality grabbag, including  */
    /* some things avatars clearly need and some which */
    /* they clearly should not be trusted with:        */
    if (job_avatar_enable_ok(u))   glEnable(u);
    --jS.s;
}

/************************************************************************/
/*-    job_P_Gla_Disable -- avatar version of glDisable			*/
/************************************************************************/

void
job_P_Gla_Disable(
    void
) {
    GLenum u = OBJ_TO_INT(*jS.s);
    job_Guarantee_N_Args(  1 );
    job_Guarantee_Int_Arg( 0 );

    /* glDisable is a functionality grabbag, including */
    /* some things avatars clearly need and some which */
    /* they clearly should not be trusted with:        */
    if (job_avatar_enable_ok(u))   glDisable(u);
    --jS.s;
}

/************************************************************************/
/* End of #if deciding whether to include OpenGL support in server.	*/
/************************************************************************/
#endif

/************************************************************************/
/*-    Following functions do NOT depend on GLUT/MESA/OpenGL		*/
/*     Thus, they can -- and should -- be outside the above #ifdef	*/
/************************************************************************/

/************************************************************************/
/* bias clamp gain gammacorrect gnoise mix smoothstep spline step	*/
/* vcnoise and vnoise are all pulled directly from			*/
/* "Texturing and Modelling: A Procedural Approach"			*/
/* by Ebert/Musgrave/Peachey/Perlin/Worley.  I love that book.		*/
/************************************************************************/

/************************************************************************/
/*-    job_P_Bias --							*/
/************************************************************************/

static double
bias(
    double b,
    double x
) {
    return pow(x, log(b)/log(0.5));
}

void
job_P_Bias(
    void
) {
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   double b = OBJ_TO_FLOAT( jS.s[-1] );
	double x = OBJ_TO_FLOAT( jS.s[ 0] );
	double r = bias(b,x);
	jS.s -= 1;
	*jS.s = OBJ_FROM_FLOAT(r);
    }
}

/************************************************************************/
/*-    job_P_Clamp --							*/
/************************************************************************/

void
job_P_Clamp(
    void
) {
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   double a = OBJ_TO_FLOAT( jS.s[-2] );
        double b = OBJ_TO_FLOAT( jS.s[-1] );
	double x = OBJ_TO_FLOAT( jS.s[ 0] );
	double r = (x<a ? a : (x>b ? b : x));
	jS.s -= 1;
	*jS.s = OBJ_FROM_FLOAT(r);
    }
}

/************************************************************************/
/*-    job_P_Gain --							*/
/************************************************************************/

void
job_P_Gain(
    void
) {
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   double g = OBJ_TO_FLOAT( jS.s[-1] );
	double x = OBJ_TO_FLOAT( jS.s[ 0] );
	double r;

	if (x < 0.5)    r =       bias( 1.0-g,       2.0*x ) * 0.5;
	else            r = 1.0 - bias( 1.0-g, 2.0 - 2.0*x ) * 0.5;

	jS.s -= 1;
	*jS.s = OBJ_FROM_FLOAT(r);
    }
    MUQ_WARN("gain unimplemented");
}

/************************************************************************/
/*-    job_P_Gammacorrect --						*/
/************************************************************************/

void
job_P_Gammacorrect(
    void
) {
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   double g = OBJ_TO_FLOAT( jS.s[-1] );
	double x = OBJ_TO_FLOAT( jS.s[ 0] );
	double r;

	if (g==0.0)  g = 1.0;

	r = pow(x, 1/g);

	jS.s -= 1;
	*jS.s = OBJ_FROM_FLOAT(r);
    }
}

/************************************************************************/
/*-    job_P_Spline --							*/
/************************************************************************/

#undef CR00
#undef CR01
#undef CR02
#undef CR03
#undef CR10
#undef CR11
#undef CR12
#undef CR13
#undef CR20
#undef CR21
#undef CR22
#undef CR23
#undef CR30
#undef CR31
#undef CR32
#undef CR33

/* Coefficients of basis matrix: */
#define CR00  0.5
#define CR01  1.5
#define CR02 -1.5
#define CR03  0.5
#define CR10  1.0
#define CR11 -2.5
#define CR12  2.0
#define CR13 -0.5
#define CR20 -0.5
#define CR21  0.0
#define CR22  0.5
#define CR23  0.0
#define CR30  0.0
#define CR31  1.0
#define CR32  0.0
#define CR33  0.0

static float
splinef(
    float  x,
    Vm_Int nknots,
    float* knot
) {
    int span;
    int nspans = nknots-3;
    float c0,c1,c2,c3; /* Cubic coefficients */
    if (nspans < 1) MUQ_WARN("spline: too few knots");
    x = (x<0.0 ? 0.0 : (x>1.0 ? 1.0 : x)) * (float)nspans;
    span = (int) x;
    if (span > nknots-3) {
	span = nknots-3;
    }
    x    -= span;
    knot += span;

    /* Evaluate span cubic at X using Horner's rule: */
    c3 = CR00*knot[0] + CR01*knot[1]
       + CR02*knot[2] + CR03*knot[3];
    c2 = CR10*knot[0] + CR11*knot[1]
       + CR12*knot[2] + CR13*knot[3];
    c1 = CR20*knot[0] + CR21*knot[1]
       + CR22*knot[2] + CR23*knot[3];
    c0 = CR30*knot[0] + CR31*knot[1]
       + CR32*knot[2] + CR33*knot[3];

    return ((c3*x + c2)*x + c1)*x + c0;
}

static float
splined(
    double  x,
    Vm_Int  nknots,
    double* knot
) {
    int span;
    int nspans = nknots-3;
    double c0,c1,c2,c3; /* Cubic coefficients */
    if (nspans < 1) MUQ_WARN("spline: too few knots");
    x = (x<0.0 ? 0.0 : (x>1.0 ? 1.0 : x)) * (double)nspans;
    span = (int) x;
    if (span > nknots-3) {
	span = nknots-3;
    }
    x    -= span;
    knot += span;

    /* Evaluate span cubic at X using Horner's rule: */
    c3 = CR00*knot[0] + CR01*knot[1]
       + CR02*knot[2] + CR03*knot[3];
    c2 = CR10*knot[0] + CR11*knot[1]
       + CR12*knot[2] + CR13*knot[3];
    c1 = CR20*knot[0] + CR21*knot[1]
       + CR22*knot[2] + CR23*knot[3];
    c0 = CR30*knot[0] + CR31*knot[1]
       + CR32*knot[2] + CR33*knot[3];

    return ((c3*x + c2)*x + c1)*x + c0;
}

void
job_P_Spline(
    void
) {
    Vm_Obj v = jS.s[-1];
    job_Guarantee_N_Args(    2 );
    job_Guarantee_Float_Arg( 0 );
    if (OBJ_IS_OBJ(v)) {
        if (OBJ_IS_F32(v)) {
	    Vm_Int nknots = f32_Len(      jS.s[-1] );
	    F32_P pknot   = vm_Loc(       jS.s[-1] );
	    float*knot    = &pknot->slot[0];
	    float x       = OBJ_TO_FLOAT( jS.s[ 0] );
	    float r       = splinef(x,nknots,knot);
	    jS.s -= 1;
	    *jS.s = OBJ_FROM_FLOAT(r);
	    return;
	}
	if (OBJ_IS_F64(v)) {
	    Vm_Int nknots = f64_Len(      jS.s[-1] );
	    F64_P pknot   = vm_Loc(       jS.s[-1] );
	    double*knot   = &pknot->slot[0];
	    double x      = OBJ_TO_FLOAT( jS.s[ 0] );
	    double r      = splined(x,nknots,knot);
	    jS.s -= 1;
	    *jS.s = OBJ_FROM_FLOAT(r);
	    return;
	}
	if (OBJ_IS_VEC(v) && vec_Is_All_Floats(v)) {
	    Vm_Int nknots = vec_Len(      jS.s[-1] );
	    Vec_P  pknot  = VEC_P(        jS.s[-1] );
	    double*knot   = (double*)&pknot->slot[0];
	    double x      = OBJ_TO_FLOAT( jS.s[ 0] );
	    double r      = splined(x,nknots,knot);
	    jS.s -= 1;
	    *jS.s = OBJ_FROM_FLOAT(r);
	    return;
	}
    }
    job_Guarantee_F32_Arg(  -1 );
}

#undef CR00
#undef CR01
#undef CR02
#undef CR03
#undef CR10
#undef CR11
#undef CR12
#undef CR13
#undef CR20
#undef CR21
#undef CR22
#undef CR23
#undef CR30
#undef CR31
#undef CR32
#undef CR33

/************************************************************************/
/*-    job_P_Vnoise --							*/
/************************************************************************/

#undef TABSIZE
#undef TABMASK
#undef PERM
#undef INDEX

#define TABSIZE 256
#define TABMASK (TABSIZE-1)
#define PERM(x) perm[(x)&TABMASK]
#define INDEX(ix,iy,iz) PERM((ix)+PERM((iy)+PERM(iz)))

static unsigned char
perm[TABSIZE] = {
    255,155,210,108,175,199,221,144,203,116, 70,213, 69,158, 33,252,
      5, 82,173,133,222,139,174, 27,  9, 71, 90,246, 75,130, 91,191,
    169,138,  2,151,194,235, 81,  7, 25,113,228,159,205,253,134,142,
    248, 65,224,217, 22,121,229, 63, 89,103, 96,104,156, 17,201,129,
     36,  8,165,110,237,117,231, 56,132,211,152, 20,181,111,239,218,
    170,163, 51,172,157, 47, 80,212,176,250, 87, 49, 99,242,136,189,
    162,115, 44, 43,124, 94,150, 16,141,247, 32, 10,198,223,255, 72,
     53,131, 84, 57,220,197, 58, 50,208, 11,241, 28,  3,192, 62,202,
     18,215,153, 24, 76, 41, 15,179, 39, 46, 55,  6,128,167, 23,188,
    106, 34,187,140,164, 73,112,182,244,195,227, 13, 35, 77,196,185,
     26,200,226,119, 31,123,168,125,249, 68,183,230,177,135,160,180,
     12,  1,243,148,102,166, 38,238,251, 37,240,126, 64, 74,161, 40,
    184,149,171,178,101, 66, 29, 59,146, 61,254,107, 42, 86,154,  4,
    236,232,120, 21,233,209, 45, 98,193,114, 78, 19,206, 14,118,127,
     48, 79,147, 85, 30,207,219, 54, 88,234,190,122, 95, 67,143,109,
    137,214,145, 93, 92,100,245,  0,216,186, 60, 83,105, 97,204, 52
};

#undef RANDMASK
#undef RANDNBR
#define RANDMASK 0x7fffffff
#define RANDNBR ((random() & RANDMASK)/(double)RANDMASK)

#define FLOOR(x) ((int)(x) - ((x) < 0 && (x) != (int)(x)))

static float valueTab[TABSIZE];

static void
valueTabInit(
    int seed
) {
    float* table = valueTab;
    int    i;
    srandom(seed);
    for (i = 0;   i < TABSIZE;  i++) {
        *table++ = 1.0 - 2.0 * RANDNBR;
    }
}
    
static float
vlattice(
    int ix,
    int iy,
    int iz
) {
    return valueTab[ INDEX(ix,iy,iz) ];
}

static float
vnoise(
    float x,
    float y,
    float z
) {
    int   ix,iy,iz;
    int   i, j, k ;
    float fx,fy,fz;

    float xknots[4];
    float yknots[4];
    float zknots[4];

    static int initialized = FALSE;

    if(!initialized) {
	initialized  = TRUE;
	valueTabInit( 665 );
    }

    ix = FLOOR(x);    fx = x - ix;
    iy = FLOOR(y);    fy = y - iy;
    iz = FLOOR(z);    fz = z - iz;

    for         (k = -1;   k <= 2;   k++) {
        for     (j = -1;   j <= 2;   j++) {
            for (i = -1;   i <= 2;   i++) {
	        xknots[i+1] = vlattice(ix+i,iy+j,iz+k); }
	    yknots[    j+i] = splinef( fx, 4, xknots );  }
	zknots[        k+i] = splinef( fy, 4, yknots );  }
    return                    splinef( fz, 4, zknots );
}

void
job_P_Vnoise(
    void
) {
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   double x = OBJ_TO_FLOAT( jS.s[-2] );
        double y = OBJ_TO_FLOAT( jS.s[-1] );
	double z = OBJ_TO_FLOAT( jS.s[ 0] );
	double r = vnoise( x, y, z );
	jS.s    -= 2;
	*jS.s    = OBJ_FROM_FLOAT(r);
    }
}

/************************************************************************/
/*-    job_P_Gnoise --							*/
/************************************************************************/

float gradientTable[ TABSIZE * 3 ];

static void
gradientTabInit(
    int seed
) {
    float * table = gradientTable;
    float   z, r, theta;
    int     i;

    srandom( seed );

    for (i = 0;   i < TABSIZE;   ++i) {
	z = 1.0 - 2.0 * RANDNBR;
	/* r is radius of x,y circle: */
	r = sqrt( 1.0  - z*z );	   /* sqrtf in original */
	/* theta is an angle in x,y:  */
	theta = 2.0 * M_PI * RANDNBR;
	*table++ = r * cos(theta); /* cosf in original */
	*table++ = r * sin(theta); /* sinf in original */
	*table++ = z;
    }
}

static float
glattice(
    int   ix, int   iy, int   iz,
    float fx, float fy, float fz
){
    float* g = &gradientTable[ INDEX(ix,iy,iz) * 3 ];
    return g[0]*fx + g[1]*fy + g[2]*fz;
}

#undef  LERP
#define LERP(t,x0,x1) ((x0) + (t)*((x1)-(x0)))

#undef  SMOOTHSTEP
#define SMOOTHSTEP(x) ((x)*(x)*(3 - 2*(x)))

float
gnoise(
    float x,
    float y,
    float z
) {
    int   ix, iy, iz;
    float wx, wy, wz;

    float fx0, fx1;
    float fy0, fy1;
    float fz0, fz1;

    float vx0, vx1;
    float vy0, vy1;
    float vz0, vz1;

    static int initialized = FALSE;

    if(!initialized) {
	initialized   = TRUE;
	gradientTabInit(665);
    }

    ix = FLOOR(x);   fx0 = x - ix;   fx1 = fx0 - 1.0;   wx = SMOOTHSTEP(fx0);
    iy = FLOOR(y);   fy0 = y - iy;   fy1 = fy0 - 1.0;   wy = SMOOTHSTEP(fy0);
    iz = FLOOR(z);   fz0 = z - iz;   fz1 = fz0 - 1.0;   wz = SMOOTHSTEP(fz0);

    vx0 = glattice( ix, iy  ,iz  ,fx0,fy0,fz0); vx1 = glattice( ix+1,iy  ,iz  ,fx1,fy0,fz0);  vy0 = LERP(wx,vx0,vx1);
    vx0 = glattice( ix, iy+1,iz  ,fx0,fy1,fz0); vx1 = glattice( ix+1,iy+1,iz  ,fx1,fy1,fz0);  vy1 = LERP(wx,vx0,vx1); vz0 = LERP(wy,vy0,vy1);
    vx0 = glattice( ix, iy  ,iz+1,fx0,fy0,fz1); vx1 = glattice( ix+1,iy  ,iz+1,fx1,fy0,fz1);  vy0 = LERP(wx,vx0,vx1);
    vx0 = glattice( ix, iy+1,iz+1,fx0,fy1,fz1); vx1 = glattice( ix+1,iy+1,iz+1,fx1,fy1,fz1);  vy1 = LERP(wx,vx0,vx1); vz1 = LERP(wy,vy0,vy1);

    return LERP( wz, vz0, vz1 );
}


void
job_P_Gnoise(
    void
) {
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   double x = OBJ_TO_FLOAT( jS.s[-2] );
        double y = OBJ_TO_FLOAT( jS.s[-1] );
	double z = OBJ_TO_FLOAT( jS.s[ 0] );
	double r = gnoise( x, y, z );
	jS.s    -= 2;
	*jS.s    = OBJ_FROM_FLOAT(r);
    }
}

/************************************************************************/
/*-    job_P_Mix --							*/
/************************************************************************/

void
job_P_Mix(
    void
) {
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   double a = OBJ_TO_FLOAT( jS.s[-2] );
        double b = OBJ_TO_FLOAT( jS.s[-1] );
	double f = OBJ_TO_FLOAT( jS.s[ 0] );
	double r = (1.0-f)*a + f*b;
	jS.s -= 2;
	*jS.s = OBJ_FROM_FLOAT(r);
    }
}

/************************************************************************/
/*-    job_P_Smoothstep --						*/
/************************************************************************/

void
job_P_Smoothstep(
    void
) {
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   double a = OBJ_TO_FLOAT( jS.s[-2] );
        double b = OBJ_TO_FLOAT( jS.s[-1] );
	double x = OBJ_TO_FLOAT( jS.s[ 0] );
	double r;
	if (x < a) 	    r = (double)0.0;
	else if (x >= b)    r = (double)1.0;
	else {
	    double c = b-a;
	    if (c==(double)0.0) r = (double)1.0;
	    else {
		x = (x-a)/c;
	        r = x*x * (3 - 2*x);
	    }
	}

	jS.s -= 2;
	*jS.s = OBJ_FROM_FLOAT(r);
    }
}

/************************************************************************/
/*-    job_P_Step --							*/
/************************************************************************/

void
job_P_Step(
    void
) {
    job_Guarantee_N_Args(     2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   double a = OBJ_TO_FLOAT( jS.s[-1] );
	double x = OBJ_TO_FLOAT( jS.s[ 0] );
	double r = (x>=a) ? (double) 1.0 : (double) 0.0;
	jS.s -= 1;
	*jS.s = OBJ_FROM_FLOAT(r);
    }
}

/************************************************************************/
/*-    job_P_Vcnoise --							*/
/************************************************************************/

#undef SAMPRATE
#undef NENTRIES

#define SAMPRATE 100 /* Table entries per unit distance */
#define NENTRIES (4*SAMPRATE+1)



static float
catrom2(
    float d
) {
    float x;
    int   i;
    static float table[ NENTRIES ];
    static int   initialized = FALSE;

    if(!initialized) {
	initialized = TRUE;
	for (i = 0;   i < NENTRIES;  i++) {
	    x = i / (float) SAMPRATE;
	    x = sqrt( x );	/* sqrtf in original */
	    if (x < 1)   table[i] = 0.5 * (2+x*x*(-5+x*3));
	    else         table[i] = 0.5 * (4+x*(-8+x*(5-x)));
	}
    }

    d = d * SAMPRATE + 0.5;
    i = FLOOR(d);

    if (i >= NENTRIES)   return 0.0;
    else                 return table[i];
}

static float
vcnoise(
    float x,
    float y,
    float z
) {
    int   ix, iy, iz;
    int   i,  j,  k ;
    float fx, fy, fz;
    float dx, dy, dz;

    float sum = 0.0;

    static int initialized = FALSE;
    if(!initialized) {
	initialized  = TRUE;
	valueTabInit( 665 );
    }

    ix = FLOOR(x);   fx = x - ix;
    iy = FLOOR(y);   fy = y - iy;
    iz = FLOOR(z);   fz = z - iz;

    for         (k = -1;  k <= 2;   k++) { dz = k - fz;   dz = dz * dz;
        for     (j = -1;  j <= 2;   j++) { dy = j - fy;   dy = dy * dy;
            for (i = -1;  i <= 2;   i++) { dx = i - fx;   dx = dx * dx;

		sum += vlattice( ix+i, iy+j, iz+k ) * catrom2( dx + dy + dz );
    }	}   }

    return sum;
}

void
job_P_Vcnoise(
    void
) {
    job_Guarantee_N_Args(     3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   double x = OBJ_TO_FLOAT( jS.s[-2] );
        double y = OBJ_TO_FLOAT( jS.s[-1] );
	double z = OBJ_TO_FLOAT( jS.s[ 0] );
	double r = vcnoise( x, y, z );
	jS.s    -= 2;
	*jS.s    = OBJ_FROM_FLOAT(r);
    }
}

/************************************************************************/
/*-    job_P_Fbm -- fBm							*/
/************************************************************************/

#undef MIN_OCTAVES
#undef MAX_OCTAVES
#define MIN_OCTAVES 4
#define MAX_OCTAVES 12

static double
fBm(
    double x,
    double y,
    double z,
    double H,
    double lacunarity,
    double octaves
) {
    int    ioctaves=(int)octaves;
    double value, frequency, remainder;
    int    i;
    static double exponent_array[MAX_OCTAVES+1];
    static int    octs = 0;

    /* Precompute and store spectral weights: */
    if (ioctaves < MIN_OCTAVES) {ioctaves = MIN_OCTAVES; octaves=(double)ioctaves;}
    if (ioctaves < MAX_OCTAVES) {ioctaves = MAX_OCTAVES; octaves=(double)ioctaves;}
    if (ioctaves != octs) {
	octs = ioctaves;
        frequency = 1.0;
	for (i = 0; i <= ioctaves; i++) {
	    exponent_array[i] = pow( frequency, -H );
	    frequency *= lacunarity;
	}
    }

    value     = 0.0;
    frequency = 1.0;

    /* Inner loop of spectral construction: */
    for (i=0; i<ioctaves; i++) {
	value += vnoise( x, y, z ) * exponent_array[i];
	x     *= lacunarity;
	y     *= lacunarity;
	z     *= lacunarity;
    }

    remainder = octaves - ioctaves;
    if (remainder > 0.0) {
	value += remainder * vnoise(x,y,z) * exponent_array[i];
    }

    return value;
}


void
job_P_Fbm(
    void
) {
    job_Guarantee_N_Args(     6 );
    job_Guarantee_Float_Arg( -5 );
    job_Guarantee_Float_Arg( -4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   double x = OBJ_TO_FLOAT( jS.s[-5] );
        double y = OBJ_TO_FLOAT( jS.s[-4] );
	double z = OBJ_TO_FLOAT( jS.s[-3] );
        double H = OBJ_TO_FLOAT( jS.s[-2] );
        double l = OBJ_TO_FLOAT( jS.s[-1] );
	double o = OBJ_TO_UNT(   jS.s[ 0] );
	double r = fBm( x,y,z, H, l, o );
	jS.s    -= 5;
	*jS.s    = OBJ_FROM_FLOAT(r);
    }
}

/************************************************************************/
/*-    job_P_Turbulence -- 						*/
/************************************************************************/

static double
turbulence(
    float x,
    float y,
    float z,
    float lo,
    float hi
) {
    float freq, t;
    x += 123.456;

    t = 0.0;

    if (lo <  1.0) lo =  1.0;
    if (hi > 14.0) hi = 14.0;

    for (freq = lo; freq < hi; freq *= 2.0) {
	t += fabs( gnoise(x,y,z) ) / freq;
	x *= 2.0;
	y *= 2.0;
	z *= 2.0;
    }

    return t - 0.3;  /* make mean returned value 0.0 */
}


void
job_P_Turbulence(
    void
) {
    job_Guarantee_N_Args(     5 );
    job_Guarantee_Float_Arg( -4 );
    job_Guarantee_Float_Arg( -3 );
    job_Guarantee_Float_Arg( -2 );
    job_Guarantee_Float_Arg( -1 );
    job_Guarantee_Float_Arg(  0 );
    {   double x  = OBJ_TO_FLOAT( jS.s[-4] );
        double y  = OBJ_TO_FLOAT( jS.s[-3] );
	double z  = OBJ_TO_FLOAT( jS.s[-2] );
        double lo = OBJ_TO_FLOAT( jS.s[-1] );
        double hi = OBJ_TO_FLOAT( jS.s[ 0] );
	double r = turbulence( x,y,z, lo, hi );
	jS.s    -= 4;
	*jS.s    = OBJ_FROM_FLOAT(r);
    }
}

/************************************************************************/
/*-    job_get_point							*/
/************************************************************************/

static int
job_get_point(
    double* x,
    double* y,
    double* z,
    int     i
) {
    Vm_Obj v = jS.s[i];
    if (OBJ_IS_FLOAT(v)) {
	double f = OBJ_TO_FLOAT(v);
	*x = f;
	*y = f;
	*z = f;
	return TRUE;
    }
    if (OBJ_IS_F32(v)) {
	Vm_Int len   = f32_Len(      jS.s[i] );
	F32_P  f     = vm_Loc(       jS.s[i] );
	float* p     = &f->slot[0];
	if (len != 3) MUQ_WARN("Needed len-3 vector");
	*x = p[0];
	*y = p[1];
	*z = p[2];
	return TRUE;
    }
    if (OBJ_IS_F64(v)) {
	Vm_Int len    = f64_Len(      jS.s[i] );
	F64_P  f      = vm_Loc(       jS.s[i] );
	double*p      = &f->slot[0];
	if (len != 3) MUQ_WARN("Needed len-3 vector");
	*x = p[0];
	*y = p[1];
	*z = p[2];
	return FALSE;
    }
    if (OBJ_IS_VEC(v) && vec_Is_All_Floats(v)) {
	Vm_Int len    = vec_Len(      jS.s[i] );
	Vec_P  f      = VEC_P(        jS.s[i] );
	Vm_Obj*p      = &f->slot[0];
	if (len != 3) MUQ_WARN("Needed len-3 vector");
	*x  = OBJ_TO_FLOAT( p[0] );
	*y  = OBJ_TO_FLOAT( p[1] );
	*z  = OBJ_TO_FLOAT( p[2] );
	return FALSE;
    }
    job_Guarantee_F32_Arg( i );
    return FALSE;	/* Just to quiet compilers. */
}

/************************************************************************/
/*-    job_P_Cross_Product -- crossProduct				*/
/************************************************************************/

#undef X
#undef Y
#undef Z

#define X slot[0]
#define Y slot[1]
#define Z slot[2]

void
job_P_Cross_Product(
    void
) {
    double aX, aY, aZ;
    double bX, bY, bZ;

    int both_32 = TRUE;

    job_Guarantee_N_Args( 2 );

    both_32    &= job_get_point( &aX, &aY, &aZ, -1 );
    both_32    &= job_get_point( &bX, &bY, &bZ,  0 );

    if (both_32) {

        Vm_Obj result = f32_Alloc( 3, OBJ_FROM_FLOAT(0.0) );

	F32_P  r = F32_P(result);

	r->X   =   aY * bZ   -   bY * aZ;
	r->Y   =   bX * aZ   -   aX * bZ;
	r->Z   =   aX * bY   -   bX * aY;

	vm_Dirty(result);

	jS.s -= 1;
	*jS.s = result;

    } else {

        Vm_Obj result = f64_Alloc( 3, OBJ_FROM_FLOAT(0.0) );

	F64_P  r = F64_P(result);

	r->X   =   aY * bZ   -   bY * aZ;
	r->Y   =   bX * aZ   -   aX * bZ;
	r->Z   =   aX * bY   -   bX * aY;

	vm_Dirty(result);

	jS.s -= 1;
	*jS.s = result;
    }
}
#undef X
#undef Y
#undef Z


/************************************************************************/
/*-    job_P_Magnitude -- magnitude					*/
/************************************************************************/

#undef fabs
#define fabs(a) ((a)<0.0 ? -(a) : (a))

static float
magnitudef(
    float x,
    float y,
    float z
) {
    /***************************************************/
    /* The naive algorithm is sqrt( x*x + y*y + z*z ); */
    /* but Numerical Recipes advises that to be too    */
    /* subject to precision problems and recommends:   */
    /***************************************************/

    float abX = fabs( x );
    float abY = fabs( y );
    float abZ = fabs( z );
    float inv;

    if (abX > abY && abX > abZ) {

	inv  = 1.0 / abX;
	abY *= inv;
	abZ *= inv;
	return abX * sqrt( 1.0 + abY * abY + abZ * abZ );

    } else if (abY > abZ) {

	inv  = 1.0 / abY;
	abX *= inv;
	abZ *= inv;
	return abY * sqrt( abX * abX + 1.0 + abZ * abZ );

    } else if (abZ != 0.0) {

	inv  = 1.0 / abZ;
	abX *= inv;
	abY *= inv;
	return abZ * sqrt( abX * abX + abY * abY + 1.0 );

    } else {

	return 0.0;
    }
}

static float
magnituded(
    double x,
    double y,
    double z
) {
    /***************************************************/
    /* The naive algorithm is sqrt( x*x + y*y + z*z ); */
    /* but Numerical Recipes advises that to be too    */
    /* subject to precision problems and recommends:   */
    /***************************************************/

    double abX = fabs( x );
    double abY = fabs( y );
    double abZ = fabs( z );
    double inv;

    if (abX > abY && abX > abZ) {

	inv  = 1.0 / abX;
	abY *= inv;
	abZ *= inv;
	return abX * sqrt( 1.0 + abY * abY + abZ * abZ );

    } else if (abY > abZ) {

	inv  = 1.0 / abY;
	abX *= inv;
	abZ *= inv;
	return abY * sqrt( abX * abX + 1.0 + abZ * abZ );

    } else if (abZ != 0.0) {

	inv  = 1.0 / abZ;
	abX *= inv;
	abY *= inv;
	return abZ * sqrt( abX * abX + abY * abY + 1.0 );

    } else {

	return 0.0;
    }
}

void
job_P_Magnitude(
    void
) {
    double x,y,z;
    double r;
    job_Guarantee_N_Args(    1 );
    if (OBJ_IS_F32(jS.s[0]) && f32_Len(jS.s[0])==3) {
        F32_P  a = vm_Loc( jS.s[0] );
        r        = magnitudef( a->slot[0], a->slot[1], a->slot[2] );
	*jS.s = OBJ_FROM_FLOAT(r);
	return;
    }
    job_get_point( &x, &y, &z,   0 );
    r        = magnituded( x, y, z );
    *jS.s = OBJ_FROM_FLOAT(r);
}

/************************************************************************/
/*-    job_P_Distance -- distance					*/
/************************************************************************/

void
job_P_Distance(
    void
) {
    Vm_Flt result;

    job_Guarantee_N_Args(    2 );

    if (OBJ_IS_F32(jS.s[-1]) && f32_Len(jS.s[-1])==3
    &&  OBJ_IS_F32(jS.s[ 0]) && f32_Len(jS.s[ 0])==3
    ){

        F32_P  a = NULL;	/* Just to quiet compilers. */
        F32_P  b = NULL;	/* Just to quiet compilers. */

	vm_Loc2( (void**)&a, (void**)&b, jS.s[-1], jS.s[0] );

	result = magnitudef(
	    a->slot[0] - b->slot[0],
	    a->slot[1] - b->slot[1],
	    a->slot[2] - b->slot[2]
	);

    } else {

	double aX,aY,aZ;
	double bX,bY,bZ;

        job_get_point( &aX, &aY, &aZ,   -1 );
        job_get_point( &bX, &bY, &bZ,    0 );

	result = magnituded(
	    aX - bX,
	    aY - bY,
	    aZ - bY
	);
    }

    jS.s -= 1;
    *jS.s = OBJ_FROM_FLOAT(result);
}

/************************************************************************/
/*-    job_P_Dot_Product -- dotProduct					*/
/************************************************************************/

void
job_P_Dot_Product(
    void
) {
    double aX, aY, aZ;
    double bX, bY, bZ;

    double r;

    job_Guarantee_N_Args( 2 );

    job_get_point( &aX, &aY, &aZ, -1 );
    job_get_point( &bX, &bY, &bZ,  0 );

    r = aX*bX + aY*bY + aZ*bZ;

    jS.s -= 1;
    *jS.s = OBJ_FROM_FLOAT(r);
}

/************************************************************************/
/*-    job_mul_vectors -- 						*/
/************************************************************************/

#undef X
#undef Y
#undef Z

#define X slot[0]
#define Y slot[1]
#define Z slot[2]

Vm_Obj
job_mul_vectors(
    Vm_Obj a,
    Vm_Obj b
){
    double aX, aY, aZ;
    double bX, bY, bZ;

    int both_32 = TRUE;

    job_Guarantee_N_Args( 2 );

    both_32    &= job_get_point( &aX, &aY, &aZ, -1 );
    both_32    &= job_get_point( &bX, &bY, &bZ,  0 );

    if (both_32) {

        Vm_Obj result = f32_Alloc( 3, OBJ_FROM_FLOAT(0.0) );

	F32_P  r = F32_P(result);

	r->X   =   aX * bX;
	r->Y   =   aY * bY;
	r->Z   =   aZ * bZ;

	vm_Dirty(result);

	return result;

    } else {

        Vm_Obj result = f64_Alloc( 3, OBJ_FROM_FLOAT(0.0) );

	F64_P  r = F64_P(result);

	r->X   =   aX * bX;
	r->Y   =   aY * bY;
	r->Z   =   aZ * bZ;

	vm_Dirty(result);

	return result;
    }
}

#undef X
#undef Y
#undef Z

/************************************************************************/
/*-    job_div_vectors -- 						*/
/************************************************************************/

#undef X
#undef Y
#undef Z

#define X slot[0]
#define Y slot[1]
#define Z slot[2]

Vm_Obj
job_div_vectors(
    Vm_Obj a,
    Vm_Obj b
){
    double aX, aY, aZ;
    double bX, bY, bZ;

    int both_32 = TRUE;

    job_Guarantee_N_Args( 2 );

    both_32    &= job_get_point( &aX, &aY, &aZ, -1 );
    both_32    &= job_get_point( &bX, &bY, &bZ,  0 );

    if (bX==0.0 || bY==0.0 || bZ==0.0) MUQ_WARN("Vector divide by zero detected");

    if (both_32) {

        Vm_Obj result = f32_Alloc( 3, OBJ_FROM_FLOAT(0.0) );

	F32_P  r = F32_P(result);

	r->X   =   aX / bX;
	r->Y   =   aY / bY;
	r->Z   =   aZ / bZ;

	vm_Dirty(result);

	return result;

    } else {

        Vm_Obj result = f64_Alloc( 3, OBJ_FROM_FLOAT(0.0) );

	F64_P  r = F64_P(result);

	r->X   =   aX / bX;
	r->Y   =   aY / bY;
	r->Z   =   aZ / bZ;

	vm_Dirty(result);

	return result;
    }
}

#undef X
#undef Y
#undef Z

/************************************************************************/
/*-    job_mod_vectors -- 						*/
/************************************************************************/

#undef X
#undef Y
#undef Z

#define X slot[0]
#define Y slot[1]
#define Z slot[2]

Vm_Obj
job_mod_vectors(
    Vm_Obj a,
    Vm_Obj b
){
    double aX, aY, aZ;
    double bX, bY, bZ;

    int both_32 = TRUE;

    job_Guarantee_N_Args( 2 );

    both_32    &= job_get_point( &aX, &aY, &aZ, -1 );
    both_32    &= job_get_point( &bX, &bY, &bZ,  0 );

    if (bX==0.0 || bY==0.0 || bZ==0.0) MUQ_WARN("Vector mod by zero detected");

    if (both_32) {

        Vm_Obj result = f32_Alloc( 3, OBJ_FROM_FLOAT(0.0) );

	F32_P  r = F32_P(result);

	r->X   =   fmod( aX, bX );
	r->Y   =   fmod( aY, bY );
	r->Z   =   fmod( aZ, bZ );

	vm_Dirty(result);

	return result;

    } else {

        Vm_Obj result = f64_Alloc( 3, OBJ_FROM_FLOAT(0.0) );

	F64_P  r = F64_P(result);

	r->X   =   fmod( aX, bX );
	r->Y   =   fmod( aY, bY );
	r->Z   =   fmod( aZ, bZ );

	vm_Dirty(result);

	return result;
    }
}

#undef X
#undef Y
#undef Z

/************************************************************************/
/*-    job_neq_vectors -- 						*/
/************************************************************************/

int
job_neq_vectors(
    Vm_Obj a,
    Vm_Obj b
){
    double aX, aY, aZ;
    double bX, bY, bZ;

    job_Guarantee_N_Args( 2 );

    job_get_point( &aX, &aY, &aZ, -1 );
    job_get_point( &bX, &bY, &bZ,  0 );

    return (
	job_nearly_equal( aX, bX ) &&
	job_nearly_equal( aY, bY ) &&
	job_nearly_equal( aZ, bZ )
    );
}

/************************************************************************/
/*-    job_add_vectors -- 						*/
/************************************************************************/

#undef X
#undef Y
#undef Z

#define X slot[0]
#define Y slot[1]
#define Z slot[2]

Vm_Obj
job_add_vectors(
    Vm_Obj a,
    Vm_Obj b
){
    double aX, aY, aZ;
    double bX, bY, bZ;

    int both_32 = TRUE;

    job_Guarantee_N_Args( 2 );

    both_32    &= job_get_point( &aX, &aY, &aZ, -1 );
    both_32    &= job_get_point( &bX, &bY, &bZ,  0 );

    if (both_32) {

        Vm_Obj result = f32_Alloc( 3, OBJ_FROM_FLOAT(0.0) );

	F32_P  r = F32_P(result);

	r->X   =   aX + bX;
	r->Y   =   aY + bY;
	r->Z   =   aZ + bZ;

	vm_Dirty(result);

	return result;

    } else {

        Vm_Obj result = f64_Alloc( 3, OBJ_FROM_FLOAT(0.0) );

	F64_P  r = F64_P(result);

	r->X   =   aX + bX;
	r->Y   =   aY + bY;
	r->Z   =   aZ + bZ;

	vm_Dirty(result);

	return result;
    }
}

#undef X
#undef Y
#undef Z


/************************************************************************/
/*-    job_sub_vectors -- 						*/
/************************************************************************/

#undef X
#undef Y
#undef Z

#define X slot[0]
#define Y slot[1]
#define Z slot[2]

Vm_Obj
job_sub_vectors(
    Vm_Obj a,
    Vm_Obj b
){
    double aX, aY, aZ;
    double bX, bY, bZ;

    int both_32 = TRUE;

    job_Guarantee_N_Args( 2 );

    both_32    &= job_get_point( &aX, &aY, &aZ, -1 );
    both_32    &= job_get_point( &bX, &bY, &bZ,  0 );

    if (both_32) {

        Vm_Obj result = f32_Alloc( 3, OBJ_FROM_FLOAT(0.0) );

	F32_P  r = F32_P(result);

	r->X   =   aX - bX;
	r->Y   =   aY - bY;
	r->Z   =   aZ - bZ;

	vm_Dirty(result);

	return result;

    } else {

        Vm_Obj result = f64_Alloc( 3, OBJ_FROM_FLOAT(0.0) );

	F64_P  r = F64_P(result);

	r->X   =   aX - bX;
	r->Y   =   aY - bY;
	r->Z   =   aZ - bZ;

	vm_Dirty(result);

	return result;
    }
}

#undef X
#undef Y
#undef Z

/************************************************************************/
/*-    job_neg_vector -- 						*/
/************************************************************************/

#undef X
#undef Y
#undef Z

#define X slot[0]
#define Y slot[1]
#define Z slot[2]

Vm_Obj
job_neg_vector(
    Vm_Obj a
){
    double aX, aY, aZ;

    int both_32 = TRUE;

    job_Guarantee_N_Args( 1 );

    both_32    &= job_get_point( &aX, &aY, &aZ,  0 );

    if (both_32) {

        Vm_Obj result = f32_Alloc( 3, OBJ_FROM_FLOAT(0.0) );

	F32_P  r = F32_P(result);

	r->X   =   - aX;
	r->Y   =   - aY;
	r->Z   =   - aZ;

	vm_Dirty(result);

	return result;

    } else {

        Vm_Obj result = f64_Alloc( 3, OBJ_FROM_FLOAT(0.0) );

	F64_P  r = F64_P(result);

	r->X   =   - aX;
	r->Y   =   - aY;
	r->Z   =   - aZ;

	vm_Dirty(result);

	return result;
    }
}

#undef X
#undef Y
#undef Z


/************************************************************************/
/*-    job_P_Normalize -- normalize					*/
/************************************************************************/

static void
normalized(
    double* x,
    double* y,
    double* z
) {
    double len = magnituded( *x, *y, *z );

    if (len > 0.1e-50) {
	double inv = 1.0 / len;

	*x *= inv;
	*y *= inv;
	*z *= inv;

    } else {

	/* Arbitrary unit vector: */
	*x = 0.0;
	*y = 0.0;
	*z = 1.0;
    }
}

void
job_P_Normalize(
    void
) {
    double x,y,z;

    job_Guarantee_N_Args(    1 );

    if (OBJ_IS_F32(jS.s[0]) && f32_Len(jS.s[0])==3) {
        float len;
        Vm_Obj result = f32_Alloc( 3, OBJ_FROM_FLOAT(0.0) );

        F32_P a       = NULL;
        F32_P r       = NULL;

	vm_Loc2( (void**)&a, (void**)&r, jS.s[0], result );

        len = magnitudef( a->slot[0], a->slot[1], a->slot[2] );

	if (len > 0.1e-50) {
	    Vm_Flt inv = 1.0 / len;

	    r->slot[0] = inv * a->slot[0];
	    r->slot[1] = inv * a->slot[1];
	    r->slot[2] = inv * a->slot[2];

	} else {

	    /* Arbitrary unit vector: */
	    r->slot[0] = 0.0;
	    r->slot[1] = 0.0;
	    r->slot[2] = 1.0;
	}

        vm_Dirty(result);
	*jS.s = result;

	return;
    }

    if (OBJ_IS_F64(jS.s[0]) && f64_Len(jS.s[0])==3) {
        double len;
        Vm_Obj result = f64_Alloc( 3, OBJ_FROM_FLOAT(0.0) );

        F64_P a       = NULL;
        F64_P r       = NULL;

	vm_Loc2( (void**)&a, (void**)&r, jS.s[0], result );

        len = magnituded( a->slot[0], a->slot[1], a->slot[2] );

	if (len > 0.1e-50) {
	    double inv = 1.0 / len;

	    r->slot[0] = inv * a->slot[0];
	    r->slot[1] = inv * a->slot[1];
	    r->slot[2] = inv * a->slot[2];

	} else {

	    /* Arbitrary unit vector: */
	    r->slot[0] = 0.0;
	    r->slot[1] = 0.0;
	    r->slot[2] = 1.0;
	}

        vm_Dirty(result);
	*jS.s = result;

	return;
    }

    if (OBJ_IS_VEC(jS.s[0]) && vec_Len(jS.s[0])==3) {

        Vm_Obj result = vec_Alloc( 3, OBJ_FROM_FLOAT(0.0) );

        Vec_P a       = NULL;
        Vec_P r       = NULL;

	vm_Loc2( (void**)&a, (void**)&r, jS.s[0], result );

	x = OBJ_TO_FLOAT( a->slot[0] );
	y = OBJ_TO_FLOAT( a->slot[1] );
	z = OBJ_TO_FLOAT( a->slot[2] );

	normalized( &x, &y, &z );
	    
	r->slot[0] = OBJ_FROM_FLOAT( x );
	r->slot[1] = OBJ_FROM_FLOAT( y );
	r->slot[2] = OBJ_FROM_FLOAT( z );

        vm_Dirty(result);
	*jS.s = result;

	return;
    }

    job_get_point( &x, &y, &z,   0 );
}

/************************************************************************/
/*-    job_P_Ray_Hits_Sphere_At -- 					*/
/************************************************************************/

void
job_P_Ray_Hits_Sphere_At(
    void
) {
    /* This one is Graphics Gems p388: */

    double oX, oY, oZ;  /* Ray origin    */
    double vX, vY, vZ;  /* Ray direction */
    double sX, sY, sZ;  /* Sphere center */
    double r;           /* Sphere radius */

    job_Guarantee_N_Args(          4 );
    job_get_point( &oX, &oY, &oZ, -3 );
    job_get_point( &vX, &vY, &vZ, -2 );
    job_get_point( &sX, &sY, &sZ, -1 );
    job_Guarantee_Float_Arg(       0 );
    r = OBJ_TO_FLOAT(         jS.s[0]);

/*  normalized( &vX, &vY, &vZ ); */

    {   double s;
        double eoX = sX - oX;
        double eoY = sY - oY;
        double eoZ = sZ - oZ;
        double v = (
	    eoX * vX +
	    eoY * vY +
	    eoZ * vZ
	);
	double disk = (
	    r*r - ((eoX*eoX + eoY*eoY + eoZ*eoZ) - v*v)
	);

	/* Handle no-intersection case: */
	if (disk < 0.0) {
	    jS.s -= 2;
	    jS.s[-1] = OBJ_NIL;
	    jS.s[ 0] = OBJ_FROM_FLOAT( 1.0e15 );
	    return;
	}

	s = v - sqrt(disk);
	if (s < 0.0) {
	    jS.s -= 2;
	    jS.s[-1] = OBJ_NIL;
	    jS.s[ 0] = OBJ_FROM_FLOAT( 1.0e15 );
	    return;
	}
            
	{   Vm_Obj result = f64_Alloc( 3, OBJ_FROM_FLOAT(0.0) );
            F64_P  p      = F64_P(result);
	    p->slot[0]    = oX + s*vX;
	    p->slot[1]    = oY + s*vY;
	    p->slot[2]    = oZ + s*vZ;
	    vm_Dirty(result);
	    jS.s -= 2;
	    jS.s[-1] = result;
	    jS.s[ 0] = OBJ_FROM_FLOAT( s );
	    return;
	}
    }
}

/************************************************************************/
/*-    job_P_Ray_Hits_Spheres_At -- 					*/
/************************************************************************/

void
job_P_Ray_Hits_Spheres_At(
    void
) {
#ifdef SOON
    double oX, oY, oZ;  /* Ray origin    */
    double vX, vY, vZ;  /* Ray direction */
    double*sX,*sY,*sZ;  /* Sphere center */
    double*r;           /* Sphere radius */

    job_Guarantee_N_Args(          4 );
    job_get_point( &oX, &oY, &oZ, -3 );
    job_get_point( &vX, &vY, &vZ, -2 );
#endif
MUQ_WARN("job_P_Ray_Hits_Spheres_At is unimplemented");
}

/************************************************************************/
/*-    job_P_Glut_Reserved_00 -> 39					*/
/************************************************************************/

void job_P_Glut_Reserved_00( void ) {}
void job_P_Glut_Reserved_01( void ) {}
void job_P_Glut_Reserved_02( void ) {}
void job_P_Glut_Reserved_03( void ) {}
void job_P_Glut_Reserved_04( void ) {}
void job_P_Glut_Reserved_05( void ) {}
void job_P_Glut_Reserved_06( void ) {}
void job_P_Glut_Reserved_07( void ) {}
void job_P_Glut_Reserved_08( void ) {}
void job_P_Glut_Reserved_09( void ) {}
void job_P_Glut_Reserved_10( void ) {}
void job_P_Glut_Reserved_11( void ) {}
void job_P_Glut_Reserved_12( void ) {}
void job_P_Glut_Reserved_13( void ) {}
void job_P_Glut_Reserved_14( void ) {}
void job_P_Glut_Reserved_15( void ) {}
void job_P_Glut_Reserved_16( void ) {}
void job_P_Glut_Reserved_17( void ) {}
void job_P_Glut_Reserved_18( void ) {}
void job_P_Glut_Reserved_19( void ) {}
void job_P_Glut_Reserved_20( void ) {}
void job_P_Glut_Reserved_21( void ) {}
void job_P_Glut_Reserved_22( void ) {}
void job_P_Glut_Reserved_23( void ) {}
void job_P_Glut_Reserved_24( void ) {}
void job_P_Glut_Reserved_25( void ) {}
void job_P_Glut_Reserved_26( void ) {}
void job_P_Glut_Reserved_27( void ) {}
void job_P_Glut_Reserved_28( void ) {}
void job_P_Glut_Reserved_29( void ) {}
void job_P_Glut_Reserved_30( void ) {}
void job_P_Glut_Reserved_31( void ) {}
void job_P_Glut_Reserved_32( void ) {}
void job_P_Glut_Reserved_33( void ) {}
void job_P_Glut_Reserved_34( void ) {}
void job_P_Glut_Reserved_35( void ) {}
void job_P_Glut_Reserved_36( void ) {}
void job_P_Glut_Reserved_37( void ) {}
void job_P_Glut_Reserved_38( void ) {}
void job_P_Glut_Reserved_39( void ) {}
void job_P_Glut_Reserved_40( void ) {}
void job_P_Glut_Reserved_41( void ) {}

/************************************************************************/
/*-    Quip		                                                */

/*									*/
/*									*/
/*									*/
/*									*/
/*									*/
/* 		Miracles are God cheating at solitaire.			*/
/*									*/
/*									*/
/*									*/
/*									*/
/*									*/
/* Notice how they are							*/
/* becoming less common?						*/
/* He is growing up!							*/




/************************************************************************/
/*-    File variables							*/
/************************************************************************/
/*

Local variables:
mode: c
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/
