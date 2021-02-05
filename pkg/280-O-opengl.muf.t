@c --- This file is formatted for outline-minor-mode in emacs19.  Do:
@c -^C^O^A to show All of file.
@c  ^C^O^Q to Quickfold entire file. (Leaves only top-level headings.)
@c  ^C^O^T to hide all Text. (Leaves all headings.)
@c  ^C^O^I to show Immediate children of node.
@c  ^C^O^S to Show all of a node.
@c  ^C^O^D to hiDe all of a node.
@c  ^HFoutline-mode for more details.
@c  (Or do ^HI and read emacs:outline mode.)
@example  @c

( - 280-O-opengl.muf -- OpenGL constants and such                       )
( - This file is formatted for outline-minor-mode in emacs19.           )
( -^C^O^A shows All of file.                                            )
(  ^C^O^Q Quickfolds entire file. (Leaves only top-level headings.)     )
(  ^C^O^T hides all Text. (Leaves all headings.)                        )
(  ^C^O^I shows Immediate children of node.                             )
(  ^C^O^S Shows all of a node.                                          )
(  ^C^O^D hiDes all of a node.                                          )
(  ^HFoutline-mode gives more details.                                  )
(  (Or do ^HI and read emacs:outline mode.)                             )

( ===================================================================== )
( - Dedication and Copyright.                                           )

(  -------------------------------------------------------------------  )
(                                                                       )
(               For Firiss:  Aefrit, a friend.                          )
(                                                                       )
(  -------------------------------------------------------------------  )

(  -------------------------------------------------------------------  )
( Author:       Jeff Prothero                                           )
( Created:      99Aug29                                                 )
( Modified:                                                             )
( Language:     MUF                                                     )
( Package:      N/A                                                     )
( Status:                                                               )
(                                                                       )
(  Copyright (c) 2000, by Jeff Prothero.                                )
(                                                                       )
(  This program is free software; you may use, distribute and/or modify )
(  it under the terms of the GNU Library General Public License as      )
(  published by the Free Software Foundation; either version 2, or at   )
(  your option  any later version FOR NONCOMMERCIAL PURPOSES.           )
(                                                                       )
(  COMMERCIAL operation allowable at $100/CPU/YEAR.                     )
(  COMMERCIAL distribution (e.g., on CD-ROM) is UNRESTRICTED.           )
(  Other commercial arrangements NEGOTIABLE.                            )
(  Contact cynbe@@eskimo.com for a COMMERCIAL LICENSE.                  )
(                                                                       )
(    This program is distributed in the hope that it will be useful,    )
(    but WITHOUT ANY WARRANTY; without even the implied warranty of     )
(    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the      )
(    GNU Library General Public License for more details.               )
(                                                                       )
(    You should have received a copy of the GNU General Public License  )
(    along with this program: COPYING.LIB; if not, write to:            )
(       Free Software Foundation, Inc.                                  )
(       675 Mass Ave, Cambridge, MA 02139, USA.                         )
(                                                                       )
( Jeff Prothero DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,  )
( INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN   )
( NO EVENT SHALL JEFF PROTHERO BE LIABLE FOR ANY SPECIAL, INDIRECT OR   )
( CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS   )
( OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,            )
( NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION  )
( WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.                         )
(                                                                       )
( Please send bug reports/fixes etc to bugs@@muq.org.                   )
(  -------------------------------------------------------------------  )

( ===================================================================== )
( - Quote			                                        )

(  -------------------------------------------------------------------  )
(                                                                       )
(            It is not enough to believe what you see.                  )
(            You must also understand what you see.                     )
(                                                                       )
(                            -- Leonardo da Vinci                       )
(                                                                       )
(  -------------------------------------------------------------------  )

( ===================================================================== )
( - Select MUF Package:                                                 )

( Eventually these should probably go in a 'gl' package 'used' by muf:  )
"muf" inPackage

( ===================================================================== )
( - constants                                                           )

( Just to amuse C programmers: )
nil -->constant NULL
nil -->constant FALSE
t   -->constant TRUE

( Display mode bit masks: )
0   -->constant GLUT_RGB                        'GLUT_RGB               export
0   -->constant GLUT_RGBA                       'GLUT_RGBA              export
1   -->constant GLUT_INDEX                      'GLUT_INDEX             export
0   -->constant GLUT_SINGLE                     'GLUT_SINGLE            export
2   -->constant GLUT_DOUBLE                     'GLUT_DOUBLE            export
4   -->constant GLUT_ACCUM                      'GLUT_ACCUM             export
8   -->constant GLUT_ALPHA                      'GLUT_ALPHA             export
16  -->constant GLUT_DEPTH                      'GLUT_DEPTH             export
32  -->constant GLUT_STENCIL                    'GLUT_STENCIL           export
128 -->constant GLUT_MULTISAMPLE                'GLUT_MULTISAMPLE       export
256 -->constant GLUT_STEREO                     'GLUT_STEREO            export
512 -->constant GLUT_LUMINANCE                  'GLUT_LUMINANCE         export

( Mouse buttons: )
0 -->constant GLUT_LEFT_BUTTON                  'GLUT_LEFT_BUTTON       export
1 -->constant GLUT_MIDDLE_BUTTON                'GLUT_MIDDLE_BUTTON     export
2 -->constant GLUT_RIGHT_BUTTON                 'GLUT_RIGHT_BUTTON      export

( Mouse button  state: )
0 -->constant GLUT_DOWN                         'GLUT_DOWN              export
1 -->constant GLUT_UP                           'GLUT_UP                export

( Function keys: )
1  -->constant GLUT_KEY_F1                      'GLUT_KEY_F1            export
2  -->constant GLUT_KEY_F2                      'GLUT_KEY_F2            export
3  -->constant GLUT_KEY_F3                      'GLUT_KEY_F3            export
4  -->constant GLUT_KEY_F4                      'GLUT_KEY_F4            export
5  -->constant GLUT_KEY_F5                      'GLUT_KEY_F5            export
6  -->constant GLUT_KEY_F6                      'GLUT_KEY_F6            export
7  -->constant GLUT_KEY_F7                      'GLUT_KEY_F7            export
8  -->constant GLUT_KEY_F8                      'GLUT_KEY_F8            export
9  -->constant GLUT_KEY_F9                      'GLUT_KEY_F9            export
10 -->constant GLUT_KEY_F10                     'GLUT_KEY_F10           export
11 -->constant GLUT_KEY_F11                     'GLUT_KEY_F11           export
12 -->constant GLUT_KEY_F12                     'GLUT_KEY_F12           export

( Directional keys: )
100 -->constant GLUT_KEY_LEFT                   'GLUT_KEY_LEFT          export
101 -->constant GLUT_KEY_UP                     'GLUT_KEY_UP            export
102 -->constant GLUT_KEY_RIGHT                  'GLUT_KEY_RIGHT         export
103 -->constant GLUT_KEY_DOWN                   'GLUT_KEY_DOWN          export
104 -->constant GLUT_KEY_PAGE_UP                'GLUT_KEY_PAGE_UP       export
105 -->constant GLUT_KEY_PAGE_DOWN              'GLUT_KEY_PAGE_DOWN     export
106 -->constant GLUT_KEY_HOME                   'GLUT_KEY_HOME          export
107 -->constant GLUT_KEY_END                    'GLUT_KEY_END           export
108 -->constant GLUT_KEY_INSERT                 'GLUT_KEY_INSERT        export

( Entry/exit  state: )
0 -->constant GLUT_LEFT                         'GLUT_LEFT              export
1 -->constant GLUT_ENTERED                      'GLUT_ENTERED           export

( Menu usage  state: )
0 -->constant GLUT_MENU_NOT_IN_USE              'GLUT_MENU_NOT_IN_USE   export
1 -->constant GLUT_MENU_IN_USE                  'GLUT_MENU_IN_USE       export

( Visibility  state: )
0 -->constant GLUT_NOT_VISIBLE                  'GLUT_NOT_VISIBLE       export
1 -->constant GLUT_VISIBLE                      'GLUT_VISIBLE           export

( Window status state: )
0 -->constant GLUT_HIDDEN                       'GLUT_HIDDEN            export
1 -->constant GLUT_FULLY_RETAINED               'GLUT_FULLY_RETAINED    export
2 -->constant GLUT_PARTIALLY_RETAINED           'GLUT_PARTIALLY_RETAINED        export
3 -->constant GLUT_FULLY_COVERED                'GLUT_FULLY_COVERED     export

( Color index component selection values: )
0 -->constant GLUT_RED                          'GLUT_RED               export
1 -->constant GLUT_GREEN                        'GLUT_GREEN             export
2 -->constant GLUT_BLUE                         'GLUT_BLUE              export

( Layers for use: )
0 -->constant GLUT_NORMAL                       'GLUT_NORMAL            export
1 -->constant GLUT_OVERLAY                      'GLUT_OVERLAY           export

( glutGet parameters: )
100 -->constant GLUT_WINDOW_X                   'GLUT_WINDOW_X                  export
101 -->constant GLUT_WINDOW_Y                   'GLUT_WINDOW_Y                  export
102 -->constant GLUT_WINDOW_WIDTH               'GLUT_WINDOW_WIDTH              export
103 -->constant GLUT_WINDOW_HEIGHT              'GLUT_WINDOW_HEIGHT             export
104 -->constant GLUT_WINDOW_BUFFER_SIZE         'GLUT_WINDOW_BUFFER_SIZE        export
105 -->constant GLUT_WINDOW_STENCIL_SIZE        'GLUT_WINDOW_STENCIL_SIZE       export
106 -->constant GLUT_WINDOW_DEPTH_SIZE          'GLUT_WINDOW_DEPTH_SIZE         export
107 -->constant GLUT_WINDOW_RED_SIZE            'GLUT_WINDOW_RED_SIZE           export
108 -->constant GLUT_WINDOW_GREEN_SIZE          'GLUT_WINDOW_GREEN_SIZE         export
109 -->constant GLUT_WINDOW_BLUE_SIZE           'GLUT_WINDOW_BLUE_SIZE          export
110 -->constant GLUT_WINDOW_ALPHA_SIZE          'GLUT_WINDOW_ALPHA_SIZE         export
111 -->constant GLUT_WINDOW_ACCUM_RED_SIZE      'GLUT_WINDOW_ACCUM_RED_SIZE     export
112 -->constant GLUT_WINDOW_ACCUM_GREEN_SIZE    'GLUT_WINDOW_ACCUM_GREEN_SIZE   export
113 -->constant GLUT_WINDOW_ACCUM_BLUE_SIZE     'GLUT_WINDOW_ACCUM_BLUE_SIZE    export
114 -->constant GLUT_WINDOW_ACCUM_ALPHA_SIZE    'GLUT_WINDOW_ACCUM_ALPHA_SIZE   export
115 -->constant GLUT_WINDOW_DOUBLEBUFFER        'GLUT_WINDOW_DOUBLEBUFFER       export
116 -->constant GLUT_WINDOW_RGBA                'GLUT_WINDOW_RGBA               export
117 -->constant GLUT_WINDOW_PARENT              'GLUT_WINDOW_PARENT             export
118 -->constant GLUT_WINDOW_NUM_CHILDREN        'GLUT_WINDOW_NUM_CHILDREN       export
119 -->constant GLUT_WINDOW_COLORMAP_SIZE       'GLUT_WINDOW_COLORMAP_SIZE      export
120 -->constant GLUT_WINDOW_NUM_SAMPLES         'GLUT_WINDOW_NUM_SAMPLES        export
121 -->constant GLUT_WINDOW_STEREO              'GLUT_WINDOW_STEREO             export
122 -->constant GLUT_WINDOW_CURSOR              'GLUT_WINDOW_CURSOR             export
200 -->constant GLUT_SCREEN_WIDTH               'GLUT_SCREEN_WIDTH              export
201 -->constant GLUT_SCREEN_HEIGHT              'GLUT_SCREEN_HEIGHT             export
202 -->constant GLUT_SCREEN_WIDTH_MM            'GLUT_SCREEN_WIDTH_MM           export
203 -->constant GLUT_SCREEN_HEIGHT_MM           'GLUT_SCREEN_HEIGHT_MM          export
300 -->constant GLUT_MENU_NUM_ITEMS             'GLUT_MENU_NUM_ITEMS            export
400 -->constant GLUT_DISPLAY_MODE_POSSIBLE      'GLUT_DISPLAY_MODE_POSSIBLE     export
500 -->constant GLUT_INIT_WINDOW_X              'GLUT_INIT_WINDOW_X             export
501 -->constant GLUT_INIT_WINDOW_Y              'GLUT_INIT_WINDOW_Y             export
502 -->constant GLUT_INIT_WINDOW_WIDTH          'GLUT_INIT_WINDOW_WIDTH         export
503 -->constant GLUT_INIT_WINDOW_HEIGHT         'GLUT_INIT_WINDOW_HEIGHT        export
504 -->constant GLUT_INIT_DISPLAY_MODE          'GLUT_INIT_DISPLAY_MODE         export
700 -->constant GLUT_ELAPSED_TIME               'GLUT_ELAPSED_TIME              export
123 -->constant GLUT_WINDOW_FORMAT_ID           'GLUT_WINDOW_FORMAT_ID          export

( glutDeviceGet parameters: )
600 -->constant GLUT_HAS_KEYBOARD               'GLUT_HAS_KEYBOARD              export
601 -->constant GLUT_HAS_MOUSE                  'GLUT_HAS_MOUSE                 export
602 -->constant GLUT_HAS_SPACEBALL              'GLUT_HAS_SPACEBALL             export
603 -->constant GLUT_HAS_DIAL_AND_BUTTON_BOX    'GLUT_HAS_DIAL_AND_BUTTON_BOX   export
604 -->constant GLUT_HAS_TABLET                 'GLUT_HAS_TABLET                export
605 -->constant GLUT_NUM_MOUSE_BUTTONS          'GLUT_NUM_MOUSE_BUTTONS         export
606 -->constant GLUT_NUM_SPACEBALL_BUTTONS      'GLUT_NUM_SPACEBALL_BUTTONS     export
607 -->constant GLUT_NUM_BUTTON_BOX_BUTTONS     'GLUT_NUM_BUTTON_BOX_BUTTONS    export
608 -->constant GLUT_NUM_DIALS                  'GLUT_NUM_DIALS                 export
609 -->constant GLUT_NUM_TABLET_BUTTONS         'GLUT_NUM_TABLET_BUTTONS        export

610 -->constant GLUT_DEVICE_IGNORE_KEY_REPEAT   'GLUT_DEVICE_IGNORE_KEY_REPEAT  export
611 -->constant GLUT_DEVICE_KEY_REPEAT          'GLUT_DEVICE_KEY_REPEAT         export
612 -->constant GLUT_HAS_JOYSTICK               'GLUT_HAS_JOYSTICK              export
613 -->constant GLUT_OWNS_JOYSTICK              'GLUT_OWNS_JOYSTICK             export
614 -->constant GLUT_JOYSTICK_BUTTONS           'GLUT_JOYSTICK_BUTTONS          export
615 -->constant GLUT_JOYSTICK_AXES              'GLUT_JOYSTICK_AXES             export
616 -->constant GLUT_JOYSTICK_POLL_RATE         'GLUT_JOYSTICK_POLL_RATE        export

( glutLayerGet parameters: )
800 -->constant GLUT_OVERLAY_POSSIBLE           'GLUT_OVERLAY_POSSIBLE          export
801 -->constant GLUT_LAYER_IN_USE               'GLUT_LAYER_IN_USE              export
802 -->constant GLUT_HAS_OVERLAY                'GLUT_HAS_OVERLAY               export
803 -->constant GLUT_TRANSPARENT_INDEX          'GLUT_TRANSPARENT_INDEX         export
804 -->constant GLUT_NORMAL_DAMAGED             'GLUT_NORMAL_DAMAGED            export
805 -->constant GLUT_OVERLAY_DAMAGED            'GLUT_OVERLAY_DAMAGED           export

( glutVideoResizeGet parameters: )
900 -->constant GLUT_VIDEO_RESIZE_POSSIBLE      'GLUT_VIDEO_RESIZE_POSSIBLE     export
901 -->constant GLUT_VIDEO_RESIZE_IN_USE        'GLUT_VIDEO_RESIZE_IN_USE       export
902 -->constant GLUT_VIDEO_RESIZE_X_DELTA       'GLUT_VIDEO_RESIZE_X_DELTA      export
903 -->constant GLUT_VIDEO_RESIZE_Y_DELTA       'GLUT_VIDEO_RESIZE_Y_DELTA      export
904 -->constant GLUT_VIDEO_RESIZE_WIDTH_DELTA   'GLUT_VIDEO_RESIZE_WIDTH_DELTA  export
905 -->constant GLUT_VIDEO_RESIZE_HEIGHT_DELTA  'GLUT_VIDEO_RESIZE_HEIGHT_DELTA export
906 -->constant GLUT_VIDEO_RESIZE_X             'GLUT_VIDEO_RESIZE_X            export
907 -->constant GLUT_VIDEO_RESIZE_Y             'GLUT_VIDEO_RESIZE_Y            export
908 -->constant GLUT_VIDEO_RESIZE_WIDTH         'GLUT_VIDEO_RESIZE_WIDTH        export
909 -->constant GLUT_VIDEO_RESIZE_HEIGHT        'GLUT_VIDEO_RESIZE_HEIGHT       export

( glutUseLayer parameters: )
0 -->constant GLUT_NORMAL                       'GLUT_NORMAL                    export
1 -->constant GLUT_OVERLAY                      'GLUT_OVERLAY                   export

( glutGetModifiers return mask: )
1 -->constant GLUT_ACTIVE_SHIFT                 'GLUT_ACTIVE_SHIFT              export
2 -->constant GLUT_ACTIVE_CTRL                  'GLUT_ACTIVE_CTRL               export
4 -->constant GLUT_ACTIVE_ALT                   'GLUT_ACTIVE_ALT                export

( glutSetCursor parameters: )
( Basic arrows: )
0 -->constant GLUT_CURSOR_RIGHT_ARROW           'GLUT_CURSOR_RIGHT_ARROW        export
1 -->constant GLUT_CURSOR_LEFT_ARROW            'GLUT_CURSOR_LEFT_ARROW         export
( Symbolic cursor shapes: )
2 -->constant GLUT_CURSOR_INFO                  'GLUT_CURSOR_INFO               export
3 -->constant GLUT_CURSOR_DESTROY               'GLUT_CURSOR_DESTROY            export
4 -->constant GLUT_CURSOR_HELP                  'GLUT_CURSOR_HELP               export
5 -->constant GLUT_CURSOR_CYCLE                 'GLUT_CURSOR_CYCLE              export
6 -->constant GLUT_CURSOR_SPRAY                 'GLUT_CURSOR_SPRAY              export
7 -->constant GLUT_CURSOR_WAIT                  'GLUT_CURSOR_WAIT               export
8 -->constant GLUT_CURSOR_TEXT                  'GLUT_CURSOR_TEXT               export
9 -->constant GLUT_CURSOR_CROSSHAIR             'GLUT_CURSOR_CROSSHAIR          export

( Directional cursors: )
10 -->constant GLUT_CURSOR_UP_DOWN              'GLUT_CURSOR_UP_DOWN            export
11 -->constant GLUT_CURSOR_LEFT_RIGHT           'GLUT_CURSOR_LEFT_RIGHT         export

( Sizing cursors: )
12 -->constant GLUT_CURSOR_TOP_SIDE             'GLUT_CURSOR_TOP_SIDE           export
13 -->constant GLUT_CURSOR_BOTTOM_SIDE          'GLUT_CURSOR_BOTTOM_SIDE        export
14 -->constant GLUT_CURSOR_LEFT_SIDE            'GLUT_CURSOR_LEFT_SIDE          export
15 -->constant GLUT_CURSOR_RIGHT_SIDE           'GLUT_CURSOR_RIGHT_SIDE         export
16 -->constant GLUT_CURSOR_TOP_LEFT_CORNER      'GLUT_CURSOR_TOP_LEFT_CORNER    export
17 -->constant GLUT_CURSOR_TOP_RIGHT_CORNER     'GLUT_CURSOR_TOP_RIGHT_CORNER   export
18 -->constant GLUT_CURSOR_BOTTOM_RIGHT_CORNER  'GLUT_CURSOR_BOTTOM_RIGHT_CORNER        export
19 -->constant GLUT_CURSOR_BOTTOM_LEFT_CORNER   'GLUT_CURSOR_BOTTOM_LEFT_CORNER export

( Inherit from parent window: )
100 -->constant GLUT_CURSOR_INHERIT             'GLUT_CURSOR_INHERIT            export

( Blank cursor: )
101 -->constant GLUT_CURSOR_NONE                'GLUT_CURSOR_NONE               export

( Fullscreen crosshair -- if available: )
102 -->constant GLUT_CURSOR_FULL_CROSSHAIR      'GLUT_CURSOR_FULL_CROSSHAIR     export

( GLUT device control sub-API: )

( glutSetKeyRepeat modes: )
0 -->constant GLUT_KEY_REPEAT_OFF               'GLUT_KEY_REPEAT_OFF            export
1 -->constant GLUT_KEY_REPEAT_ON                'GLUT_KEY_REPEAT_ON             export
2 -->constant GLUT_KEY_REPEAT_DEFAULT           'GLUT_KEY_REPEAT_DEFAULT        export

( Joystick button masks: )
1 -->constant GLUT_JOYSTICK_BUTTON_A            'GLUT_JOYSTICK_BUTTON_A         export
2 -->constant GLUT_JOYSTICK_BUTTON_B            'GLUT_JOYSTICK_BUTTON_B         export
4 -->constant GLUT_JOYSTICK_BUTTON_C            'GLUT_JOYSTICK_BUTTON_C         export
8 -->constant GLUT_JOYSTICK_BUTTON_D            'GLUT_JOYSTICK_BUTTON_D         export

( GLUT game mode sub-API: )
( glutGameModeGet: )
0 -->constant GLUT_GAME_MODE_ACTIVE             'GLUT_GAME_MODE_ACTIVE          export
1 -->constant GLUT_GAME_MODE_POSSIBLE           'GLUT_GAME_MODE_POSSIBLE        export
2 -->constant GLUT_GAME_MODE_WIDTH              'GLUT_GAME_MODE_WIDTH           export
3 -->constant GLUT_GAME_MODE_HEIGHT             'GLUT_GAME_MODE_HEIGHT          export
4 -->constant GLUT_GAME_MODE_PIXEL_DEPTH        'GLUT_GAME_MODE_PIXEL_DEPTH     export
5 -->constant GLUT_GAME_MODE_REFRESH_RATE       'GLUT_GAME_MODE_REFRESH_RATE    export
6 -->constant GLUT_GAME_MODE_DISPLAY_CHANGED    'GLUT_GAME_MODE_DISPLAY_CHANGED export

( GLUT fonts: )
0 -->constant GLUT_STROKE_ROMAN
1 -->constant GLUT_STROKE_MONO_ROMAN
2 -->constant GLUT_BITMAP_9_BY_15
3 -->constant GLUT_BITMAP_8_BY_13
4 -->constant GLUT_BITMAP_TIMES_ROMAN_10
5 -->constant GLUT_BITMAP_TIMES_ROMAN_24
6 -->constant GLUT_BITMAP_HELVETICA_10
7 -->constant GLUT_BITMAP_HELVETICA_12
8 -->constant GLUT_BITMAP_HELVETICA_18

0 -->constant GL_FALSE                          'GL_FALSE               export
1 -->constant GL_TRUE                           'GL_TRUE                export

( Data types: )
5120 -->constant GL_BYTE                        'GL_BYTE                export
5121 -->constant GL_UNSIGNED_BYTE               'GL_UNSIGNED_BYTE       export
5122 -->constant GL_SHORT                       'GL_SHORT               export
5123 -->constant GL_UNSIGNED_SHORT              'GL_UNSIGNED_SHORT      export
5124 -->constant GL_INT                         'GL_INT                 export
5125 -->constant GL_UNSIGNED_INT                'GL_UNSIGNED_INT        export
5126 -->constant GL_FLOAT                       'GL_FLOAT               export
5130 -->constant GL_DOUBLE                      'GL_DOUBLE              export
5127 -->constant GL_2_BYTES                     'GL_2_BYTES             export
5128 -->constant GL_3_BYTES                     'GL_3_BYTES             export
5129 -->constant GL_4_BYTES                     'GL_4_BYTES             export

( Primitives: )
1 -->constant GL_LINES                          'GL_LINES               export
0 -->constant GL_POINTS                         'GL_POINTS              export
3 -->constant GL_LINE_STRIP                     'GL_LINE_STRIP          export
2 -->constant GL_LINE_LOOP                      'GL_LINE_LOOP           export
4 -->constant GL_TRIANGLES                      'GL_TRIANGLES           export
5 -->constant GL_TRIANGLE_STRIP                 'GL_TRIANGLE_STRIP      export
6 -->constant GL_TRIANGLE_FAN                   'GL_TRIANGLE_FAN        export
7 -->constant GL_QUADS                          'GL_QUADS               export
8 -->constant GL_QUAD_STRIP                     'GL_QUAD_STRIP          export
9 -->constant GL_POLYGON                        'GL_POLYGON             export
2883 -->constant GL_EDGE_FLAG                   'GL_EDGE_FLAG           export

( Vertex Arrays: )
32884 -->constant GL_VERTEX_ARRAY               'GL_VERTEX_ARRAY                export
32885 -->constant GL_NORMAL_ARRAY               'GL_NORMAL_ARRAY                export
32886 -->constant GL_COLOR_ARRAY                'GL_COLOR_ARRAY                 export
32887 -->constant GL_INDEX_ARRAY                'GL_INDEX_ARRAY                 export
32888 -->constant GL_TEXTURE_COORD_ARRAY        'GL_TEXTURE_COORD_ARRAY         export
32889 -->constant GL_EDGE_FLAG_ARRAY            'GL_EDGE_FLAG_ARRAY             export
32890 -->constant GL_VERTEX_ARRAY_SIZE          'GL_VERTEX_ARRAY_SIZE           export
32891 -->constant GL_VERTEX_ARRAY_TYPE          'GL_VERTEX_ARRAY_TYPE           export
32892 -->constant GL_VERTEX_ARRAY_STRIDE        'GL_VERTEX_ARRAY_STRIDE         export
32894 -->constant GL_NORMAL_ARRAY_TYPE          'GL_NORMAL_ARRAY_TYPE           export
32895 -->constant GL_NORMAL_ARRAY_STRIDE        'GL_NORMAL_ARRAY_STRIDE         export
32897 -->constant GL_COLOR_ARRAY_SIZE           'GL_COLOR_ARRAY_SIZE            export
32898 -->constant GL_COLOR_ARRAY_TYPE           'GL_COLOR_ARRAY_TYPE            export
32899 -->constant GL_COLOR_ARRAY_STRIDE         'GL_COLOR_ARRAY_STRIDE          export
32901 -->constant GL_INDEX_ARRAY_TYPE           'GL_INDEX_ARRAY_TYPE            export
32902 -->constant GL_INDEX_ARRAY_STRIDE         'GL_INDEX_ARRAY_STRIDE          export
32904 -->constant GL_TEXTURE_COORD_ARRAY_SIZE   'GL_TEXTURE_COORD_ARRAY_SIZE    export
32905 -->constant GL_TEXTURE_COORD_ARRAY_TYPE   'GL_TEXTURE_COORD_ARRAY_TYPE    export
32906 -->constant GL_TEXTURE_COORD_ARRAY_STRIDE 'GL_TEXTURE_COORD_ARRAY_STRIDE  export
32908 -->constant GL_EDGE_FLAG_ARRAY_STRIDE     'GL_EDGE_FLAG_ARRAY_STRIDE      export
32910 -->constant GL_VERTEX_ARRAY_POINTER       'GL_VERTEX_ARRAY_POINTER        export
32911 -->constant GL_NORMAL_ARRAY_POINTER       'GL_NORMAL_ARRAY_POINTER        export
32912 -->constant GL_COLOR_ARRAY_POINTER        'GL_COLOR_ARRAY_POINTER         export
32913 -->constant GL_INDEX_ARRAY_POINTER        'GL_INDEX_ARRAY_POINTER         export
32914 -->constant GL_TEXTURE_COORD_ARRAY_POINTER        'GL_TEXTURE_COORD_ARRAY_POINTER export
32915 -->constant GL_EDGE_FLAG_ARRAY_POINTER    'GL_EDGE_FLAG_ARRAY_POINTER     export
10784 -->constant GL_V2F                        'GL_V2F                         export
10785 -->constant GL_V3F                        'GL_V3F                         export
10786 -->constant GL_C4UB_V2F                   'GL_C4UB_V2F                    export
10787 -->constant GL_C4UB_V3F                   'GL_C4UB_V3F                    export
10788 -->constant GL_C3F_V3F                    'GL_C3F_V3F                     export
10789 -->constant GL_N3F_V3F                    'GL_N3F_V3F                     export
10790 -->constant GL_C4F_N3F_V3F                'GL_C4F_N3F_V3F                 export
10791 -->constant GL_T2F_V3F                    'GL_T2F_V3F                     export
10792 -->constant GL_T4F_V4F                    'GL_T4F_V4F                     export
10793 -->constant GL_T2F_C4UB_V3F               'GL_T2F_C4UB_V3F                export
10794 -->constant GL_T2F_C3F_V3F                'GL_T2F_C3F_V3F                 export
10795 -->constant GL_T2F_N3F_V3F                'GL_T2F_N3F_V3F                 export
10796 -->constant GL_T2F_C4F_N3F_V3F            'GL_T2F_C4F_N3F_V3F             export
10797 -->constant GL_T4F_C4F_N3F_V4F            'GL_T4F_C4F_N3F_V4F             export

( Matrix Mode: )
2976 -->constant GL_MATRIX_MODE                 'GL_MATRIX_MODE                 export
5888 -->constant GL_MODELVIEW                   'GL_MODELVIEW                   export
5889 -->constant GL_PROJECTION                  'GL_PROJECTION                  export
5890 -->constant GL_TEXTURE                     'GL_TEXTURE                     export

( Points: )
2832 -->constant GL_POINT_SMOOTH                'GL_POINT_SMOOTH                export
2833 -->constant GL_POINT_SIZE                  'GL_POINT_SIZE                  export
2835 -->constant GL_POINT_SIZE_GRANULARITY      'GL_POINT_SIZE_GRANULARITY      export
2834 -->constant GL_POINT_SIZE_RANGE            'GL_POINT_SIZE_RANGE            export

( Lines: )
2848 -->constant GL_LINE_SMOOTH                 'GL_LINE_SMOOTH                 export
2852 -->constant GL_LINE_STIPPLE                'GL_LINE_STIPPLE                export
2853 -->constant GL_LINE_STIPPLE_PATTERN        'GL_LINE_STIPPLE_PATTERN        export
2854 -->constant GL_LINE_STIPPLE_REPEAT         'GL_LINE_STIPPLE_REPEAT         export
2849 -->constant GL_LINE_WIDTH                  'GL_LINE_WIDTH                  export
2851 -->constant GL_LINE_WIDTH_GRANULARITY      'GL_LINE_WIDTH_GRANULARITY      export
2850 -->constant GL_LINE_WIDTH_RANGE            'GL_LINE_WIDTH_RANGE            export

( Polygons: )
6912  -->constant GL_POINT                      'GL_POINT                       export
6913  -->constant GL_LINE                       'GL_LINE                        export
6914  -->constant GL_FILL                       'GL_FILL                        export
2305  -->constant GL_CCW                        'GL_CCW                         export
2304  -->constant GL_CW                         'GL_CW                          export
1028  -->constant GL_FRONT                      'GL_FRONT                       export
1029  -->constant GL_BACK                       'GL_BACK                        export
2884  -->constant GL_CULL_FACE                  'GL_CULL_FACE                   export
2885  -->constant GL_CULL_FACE_MODE             'GL_CULL_FACE_MODE              export
2881  -->constant GL_POLYGON_SMOOTH             'GL_POLYGON_SMOOTH              export
2882  -->constant GL_POLYGON_STIPPLE            'GL_POLYGON_STIPPLE             export
2886  -->constant GL_FRONT_FACE                 'GL_FRONT_FACE                  export
2880  -->constant GL_POLYGON_MODE               'GL_POLYGON_MODE                export
32824 -->constant GL_POLYGON_OFFSET_FACTOR      'GL_POLYGON_OFFSET_FACTOR       export
10752 -->constant GL_POLYGON_OFFSET_UNITS       'GL_POLYGON_OFFSET_UNITS        export
10753 -->constant GL_POLYGON_OFFSET_POINT       'GL_POLYGON_OFFSET_POINT        export
10754 -->constant GL_POLYGON_OFFSET_LINE        'GL_POLYGON_OFFSET_LINE         export
32823 -->constant GL_POLYGON_OFFSET_FILL        'GL_POLYGON_OFFSET_FILL         export

( Display Lists: )
4864 -->constant GL_COMPILE                     'GL_COMPILE                     export
4865 -->constant GL_COMPILE_AND_EXECUTE         'GL_COMPILE_AND_EXECUTE         export
2866 -->constant GL_LIST_BASE                   'GL_LIST_BASE                   export
2867 -->constant GL_LIST_INDEX                  'GL_LIST_INDEX                  export
2864 -->constant GL_LIST_MODE                   'GL_LIST_MODE                   export


( Depth buffer: )
512  -->constant GL_NEVER                       'GL_NEVER                       export
513  -->constant GL_LESS                        'GL_LESS                        export
518  -->constant GL_GEQUAL                      'GL_GEQUAL                      export
515  -->constant GL_LEQUAL                      'GL_LEQUAL                      export
516  -->constant GL_GREATER                     'GL_GREATER                     export
517  -->constant GL_NOTEQUAL                    'GL_NOTEQUAL                    export
514  -->constant GL_EQUAL                       'GL_EQUAL                       export
519  -->constant GL_ALWAYS                      'GL_ALWAYS                      export
2929 -->constant GL_DEPTH_TEST                  'GL_DEPTH_TEST                  export
3414 -->constant GL_DEPTH_BITS                  'GL_DEPTH_BITS                  export
2931 -->constant GL_DEPTH_CLEAR_VALUE           'GL_DEPTH_CLEAR_VALUE           export
2932 -->constant GL_DEPTH_FUNC                  'GL_DEPTH_FUNC                  export
2928 -->constant GL_DEPTH_RANGE                 'GL_DEPTH_RANGE                 export
2930 -->constant GL_DEPTH_WRITEMASK             'GL_DEPTH_WRITEMASK             export
6402 -->constant GL_DEPTH_COMPONENT             'GL_DEPTH_COMPONENT             export

( Lighting: )
2896  -->constant GL_LIGHTING                   'GL_LIGHTING                    export
16384 -->constant GL_LIGHT0                     'GL_LIGHT0                      export
16385 -->constant GL_LIGHT1                     'GL_LIGHT1                      export
16386 -->constant GL_LIGHT2                     'GL_LIGHT2                      export
16387 -->constant GL_LIGHT3                     'GL_LIGHT3                      export
16388 -->constant GL_LIGHT4                     'GL_LIGHT4                      export
16389 -->constant GL_LIGHT5                     'GL_LIGHT5                      export
16390 -->constant GL_LIGHT6                     'GL_LIGHT6                      export
16391 -->constant GL_LIGHT7                     'GL_LIGHT7                      export
4613  -->constant GL_SPOT_EXPONENT              'GL_SPOT_EXPONENT               export
4614  -->constant GL_SPOT_CUTOFF                'GL_SPOT_CUTOFF                 export
4615  -->constant GL_CONSTANT_ATTENUATION       'GL_CONSTANT_ATTENUATION        export
4616  -->constant GL_LINEAR_ATTENUATION         'GL_LINEAR_ATTENUATION          export
4617  -->constant GL_QUADRATIC_ATTENUATION      'GL_QUADRATIC_ATTENUATION       export
4608  -->constant GL_AMBIENT                    'GL_AMBIENT                     export
4609  -->constant GL_DIFFUSE                    'GL_DIFFUSE                     export
4610  -->constant GL_SPECULAR                   'GL_SPECULAR                    export
5633  -->constant GL_SHININESS                  'GL_SHININESS                   export
5632  -->constant GL_EMISSION                   'GL_EMISSION                    export
4611  -->constant GL_POSITION                   'GL_POSITION                    export
4612  -->constant GL_SPOT_DIRECTION             'GL_SPOT_DIRECTION              export
5634  -->constant GL_AMBIENT_AND_DIFFUSE        'GL_AMBIENT_AND_DIFFUSE         export
5635  -->constant GL_COLOR_INDEXES              'GL_COLOR_INDEXES               export
2898  -->constant GL_LIGHT_MODEL_TWO_SIDE       'GL_LIGHT_MODEL_TWO_SIDE        export
2897  -->constant GL_LIGHT_MODEL_LOCAL_VIEWER   'GL_LIGHT_MODEL_LOCAL_VIEWER    export
2899  -->constant GL_LIGHT_MODEL_AMBIENT        'GL_LIGHT_MODEL_AMBIENT         export
1032  -->constant GL_FRONT_AND_BACK             'GL_FRONT_AND_BACK              export
2900  -->constant GL_SHADE_MODEL                'GL_SHADE_MODEL                 export
7424  -->constant GL_FLAT                       'GL_FLAT                        export
7425  -->constant GL_SMOOTH                     'GL_SMOOTH                      export
2903  -->constant GL_COLOR_MATERIAL             'GL_COLOR_MATERIAL              export
2901  -->constant GL_COLOR_MATERIAL_FACE        'GL_COLOR_MATERIAL_FACE         export
2902  -->constant GL_COLOR_MATERIAL_PARAMETER   'GL_COLOR_MATERIAL_PARAMETER    export
2977  -->constant GL_NORMALIZE                  'GL_NORMALIZE                   export

( User clipping planes: )
12288 -->constant GL_CLIP_PLANE0                'GL_CLIP_PLANE0                 export
12289 -->constant GL_CLIP_PLANE1                'GL_CLIP_PLANE1                 export
12290 -->constant GL_CLIP_PLANE2                'GL_CLIP_PLANE2                 export
12291 -->constant GL_CLIP_PLANE3                'GL_CLIP_PLANE3                 export
12292 -->constant GL_CLIP_PLANE4                'GL_CLIP_PLANE4                 export
12293 -->constant GL_CLIP_PLANE5                'GL_CLIP_PLANE5                 export

( Accumulation buffer: )
3416 -->constant GL_ACCUM_RED_BITS              'GL_ACCUM_RED_BITS              export
3417 -->constant GL_ACCUM_GREEN_BITS            'GL_ACCUM_GREEN_BITS            export
3418 -->constant GL_ACCUM_BLUE_BITS             'GL_ACCUM_BLUE_BITS             export
3419 -->constant GL_ACCUM_ALPHA_BITS            'GL_ACCUM_ALPHA_BITS            export
2944 -->constant GL_ACCUM_CLEAR_VALUE           'GL_ACCUM_CLEAR_VALUE           export
256  -->constant GL_ACCUM                       'GL_ACCUM                       export
260  -->constant GL_ADD                         'GL_ADD                         export
257  -->constant GL_LOAD                        'GL_LOAD                        export
259  -->constant GL_MULT                        'GL_MULT                        export
258  -->constant GL_RETURN                      'GL_RETURN                      export

( Alpha testing: )
3008 -->constant GL_ALPHA_TEST                  'GL_ALPHA_TEST                  export
3010 -->constant GL_ALPHA_TEST_REF              'GL_ALPHA_TEST_REF              export
3009 -->constant GL_ALPHA_TEST_FUNC             'GL_ALPHA_TEST_FUNC             export

( Blending: )
3042  -->constant GL_BLEND                      'GL_BLEND                       export
3041  -->constant GL_BLEND_SRC                  'GL_BLEND_SRC                   export
3040  -->constant GL_BLEND_DST                  'GL_BLEND_DST                   export
0     -->constant GL_ZERO                       'GL_ZERO                        export
1     -->constant GL_ONE                        'GL_ONE                         export
768   -->constant GL_SRC_COLOR                  'GL_SRC_COLOR                   export
769   -->constant GL_ONE_MINUS_SRC_COLOR        'GL_ONE_MINUS_SRC_COLOR         export
774   -->constant GL_DST_COLOR                  'GL_DST_COLOR                   export
775   -->constant GL_ONE_MINUS_DST_COLOR        'GL_ONE_MINUS_DST_COLOR         export
770   -->constant GL_SRC_ALPHA                  'GL_SRC_ALPHA                   export
771   -->constant GL_ONE_MINUS_SRC_ALPHA        'GL_ONE_MINUS_SRC_ALPHA         export
772   -->constant GL_DST_ALPHA                  'GL_DST_ALPHA                   export
773   -->constant GL_ONE_MINUS_DST_ALPHA        'GL_ONE_MINUS_DST_ALPHA         export
776   -->constant GL_SRC_ALPHA_SATURATE         'GL_SRC_ALPHA_SATURATE          export
32769 -->constant GL_CONSTANT_COLOR             'GL_CONSTANT_COLOR              export
32770 -->constant GL_ONE_MINUS_CONSTANT_COLOR   'GL_ONE_MINUS_CONSTANT_COLOR    export
32771 -->constant GL_CONSTANT_ALPHA             'GL_CONSTANT_ALPHA              export
32772 -->constant GL_ONE_MINUS_CONSTANT_ALPHA   'GL_ONE_MINUS_CONSTANT_ALPHA    export

( Render Mode: )
7169 -->constant GL_FEEDBACK                    'GL_FEEDBACK                    export
7168 -->constant GL_RENDER                      'GL_RENDER                      export
7170 -->constant GL_SELECT                      'GL_SELECT                      export

( Feedback: )
1536 -->constant GL_2D                          'GL_2D                          export
1537 -->constant GL_3D                          'GL_3D                          export
1538 -->constant GL_3D_COLOR                    'GL_3D_COLOR                    export
1539 -->constant GL_3D_COLOR_TEXTURE            'GL_3D_COLOR_TEXTURE            export
1540 -->constant GL_4D_COLOR_TEXTURE            'GL_4D_COLOR_TEXTURE            export
1793 -->constant GL_POINT_TOKEN                 'GL_POINT_TOKEN                 export
1794 -->constant GL_LINE_TOKEN                  'GL_LINE_TOKEN                  export
1799 -->constant GL_LINE_RESET_TOKEN            'GL_LINE_RESET_TOKEN            export
1795 -->constant GL_POLYGON_TOKEN               'GL_POLYGON_TOKEN               export
1796 -->constant GL_BITMAP_TOKEN                'GL_BITMAP_TOKEN                export
1797 -->constant GL_DRAW_PIXEL_TOKEN            'GL_DRAW_PIXEL_TOKEN            export
1798 -->constant GL_COPY_PIXEL_TOKEN            'GL_COPY_PIXEL_TOKEN            export
1792 -->constant GL_PASS_THROUGH_TOKEN          'GL_PASS_THROUGH_TOKEN          export
3568 -->constant GL_FEEDBACK_BUFFER_POINTER     'GL_FEEDBACK_BUFFER_POINTER     export
3569 -->constant GL_FEEDBACK_BUFFER_SIZE        'GL_FEEDBACK_BUFFER_SIZE        export
3570 -->constant GL_FEEDBACK_BUFFER_TYPE

( Selection: )
3571 -->constant GL_SELECTION_BUFFER_POINTER    'GL_SELECTION_BUFFER_POINTER    export
3572 -->constant GL_SELECTION_BUFFER_SIZE       'GL_SELECTION_BUFFER_SIZE       export

( Fog: )
2912 -->constant GL_FOG                         'GL_FOG                         export
2917 -->constant GL_FOG_MODE                    'GL_FOG_MODE                    export
2914 -->constant GL_FOG_DENSITY                 'GL_FOG_DENSITY                 export
2918 -->constant GL_FOG_COLOR                   'GL_FOG_COLOR                   export
2913 -->constant GL_FOG_INDEX                   'GL_FOG_INDEX                   export
2915 -->constant GL_FOG_START                   'GL_FOG_START                   export
2916 -->constant GL_FOG_END                     'GL_FOG_END                     export
9729 -->constant GL_LINEAR                      'GL_LINEAR                      export
2048 -->constant GL_EXP                         'GL_EXP                         export
2049 -->constant GL_EXP2                        'GL_EXP2                        export

( Logic Ops: )
3057 -->constant GL_LOGIC_OP                    'GL_LOGIC_OP                    export
3057 -->constant GL_INDEX_LOGIC_OP              'GL_INDEX_LOGIC_OP              export
3058 -->constant GL_COLOR_LOGIC_OP              'GL_COLOR_LOGIC_OP              export
3056 -->constant GL_LOGIC_OP_MODE               'GL_LOGIC_OP_MODE               export
5376 -->constant GL_CLEAR                       'GL_CLEAR                       export
5391 -->constant GL_SET                         'GL_SET                         export
5379 -->constant GL_COPY                        'GL_COPY                        export
5388 -->constant GL_COPY_INVERTED               'GL_COPY_INVERTED               export
5381 -->constant GL_NOOP                        'GL_NOOP                        export
5386 -->constant GL_INVERT                      'GL_INVERT                      export
5377 -->constant GL_AND                         'GL_AND                         export
5390 -->constant GL_NAND                        'GL_NAND                        export
5383 -->constant GL_OR                          'GL_OR                          export
5384 -->constant GL_NOR                         'GL_NOR                         export
5382 -->constant GL_XOR                         'GL_XOR                         export
5385 -->constant GL_EQUIV                       'GL_EQUIV                       export
5378 -->constant GL_AND_REVERSE                 'GL_AND_REVERSE                 export
5380 -->constant GL_AND_INVERTED                'GL_AND_INVERTED                export
5387 -->constant GL_OR_REVERSE                  'GL_OR_REVERSE                  export
5389 -->constant GL_OR_INVERTED                 'GL_OR_INVERTED                 export

( Stencil: )
2960 -->constant GL_STENCIL_TEST                'GL_STENCIL_TEST                export
2968 -->constant GL_STENCIL_WRITEMASK           'GL_STENCIL_WRITEMASK           export
3415 -->constant GL_STENCIL_BITS                'GL_STENCIL_BITS                export
2962 -->constant GL_STENCIL_FUNC                'GL_STENCIL_FUNC                export
2963 -->constant GL_STENCIL_VALUE_MASK          'GL_STENCIL_VALUE_MASK          export
2967 -->constant GL_STENCIL_REF                 'GL_STENCIL_REF                 export
2964 -->constant GL_STENCIL_FAIL                'GL_STENCIL_FAIL                export
2966 -->constant GL_STENCIL_PASS_DEPTH_PASS     'GL_STENCIL_PASS_DEPTH_PASS     export
2965 -->constant GL_STENCIL_PASS_DEPTH_FAIL     'GL_STENCIL_PASS_DEPTH_FAIL     export
2961 -->constant GL_STENCIL_CLEAR_VALUE         'GL_STENCIL_CLEAR_VALUE         export
6401 -->constant GL_STENCIL_INDEX               'GL_STENCIL_INDEX               export
7680 -->constant GL_KEEP                        'GL_KEEP                        export
7681 -->constant GL_REPLACE                     'GL_REPLACE                     export
7682 -->constant GL_INCR                        'GL_INCR                        export
7683 -->constant GL_DECR                        'GL_DECR                        export

( Buffers, Pixel Drawing/Reading: )
0 -->constant GL_NONE                           'GL_NONE                        export
1030 -->constant GL_LEFT                        'GL_LEFT                        export
1031 -->constant GL_RIGHT                       'GL_RIGHT                       export
( GL_FRONT      )
( GL_BACK       )
( GL_FRONT_AND_BACK )
1024 -->constant GL_FRONT_LEFT                  'GL_FRONT_LEFT                  export
1025 -->constant GL_FRONT_RIGHT                 'GL_FRONT_RIGHT                 export
1026 -->constant GL_BACK_LEFT                   'GL_BACK_LEFT                   export
1027 -->constant GL_BACK_RIGHT                  'GL_BACK_RIGHT                  export
1033 -->constant GL_AUX0                        'GL_AUX0                        export
1034 -->constant GL_AUX1                        'GL_AUX1                        export
1035 -->constant GL_AUX2                        'GL_AUX2                        export
1036 -->constant GL_AUX3                        'GL_AUX3                        export
6400 -->constant GL_COLOR_INDEX                 'GL_COLOR_INDEX                 export
6403 -->constant GL_RED                         'GL_RED                         export
6404 -->constant GL_GREEN                       'GL_GREEN                       export
6405 -->constant GL_BLUE                        'GL_BLUE                        export
6406 -->constant GL_ALPHA                       'GL_ALPHA                       export
6409 -->constant GL_LUMINANCE                   'GL_LUMINANCE                   export
6410 -->constant GL_LUMINANCE_ALPHA             'GL_LUMINANCE_ALPHA             export
3413 -->constant GL_ALPHA_BITS                  'GL_ALPHA_BITS                  export
3410 -->constant GL_RED_BITS                    'GL_RED_BITS                    export
3411 -->constant GL_GREEN_BITS                  'GL_GREEN_BITS                  export
3412 -->constant GL_BLUE_BITS                   'GL_BLUE_BITS                   export
3409 -->constant GL_INDEX_BITS                  'GL_INDEX_BITS                  export
3408 -->constant GL_SUBPIXEL_BITS               'GL_SUBPIXEL_BITS               export
3072 -->constant GL_AUX_BUFFERS                 'GL_AUX_BUFFERS                 export
3074 -->constant GL_READ_BUFFER                 'GL_READ_BUFFER                 export
3073 -->constant GL_DRAW_BUFFER                 'GL_DRAW_BUFFER                 export
3122 -->constant GL_DOUBLEBUFFER                'GL_DOUBLEBUFFER                export
3123 -->constant GL_STEREO                      'GL_STEREO                      export
6656 -->constant GL_BITMAP                      'GL_BITMAP                      export
6144 -->constant GL_COLOR                       'GL_COLOR                       export
6145 -->constant GL_DEPTH                       'GL_DEPTH                       export
6146 -->constant GL_STENCIL                     'GL_STENCIL                     export
3024 -->constant GL_DITHER                      'GL_DITHER                      export
6407 -->constant GL_RGB                         'GL_RGB                         export
6408 -->constant GL_RGBA                        'GL_RGBA                        export

( Implementation limits: )
2865 -->constant GL_MAX_LIST_NESTING            'GL_MAX_LIST_NESTING            export
3381 -->constant GL_MAX_ATTRIB_STACK_DEPTH      'GL_MAX_ATTRIB_STACK_DEPTH      export
3382 -->constant GL_MAX_MODELVIEW_STACK_DEPTH   'GL_MAX_MODELVIEW_STACK_DEPTH   export
3383 -->constant GL_MAX_NAME_STACK_DEPTH        'GL_MAX_NAME_STACK_DEPTH        export
3384 -->constant GL_MAX_PROJECTION_STACK_DEPTH  'GL_MAX_PROJECTION_STACK_DEPTH  export
3385 -->constant GL_MAX_TEXTURE_STACK_DEPTH     'GL_MAX_TEXTURE_STACK_DEPTH     export
3376 -->constant GL_MAX_EVAL_ORDER              'GL_MAX_EVAL_ORDER              export
3377 -->constant GL_MAX_LIGHTS                  'GL_MAX_LIGHTS                  export
3378 -->constant GL_MAX_CLIP_PLANES             'GL_MAX_CLIP_PLANES             export
3379 -->constant GL_MAX_TEXTURE_SIZE            'GL_MAX_TEXTURE_SIZE            export
3380 -->constant GL_MAX_PIXEL_MAP_TABLE         'GL_MAX_PIXEL_MAP_TABLE         export
3386 -->constant GL_MAX_VIEWPORT_DIMS           'GL_MAX_VIEWPORT_DIMS           export
3387 -->constant GL_MAX_CLIENT_ATTRIB_STACK_DEPTH       'GL_MAX_CLIENT_ATTRIB_STACK_DEPTH       export

( Gets: )
2992 -->constant GL_ATTRIB_STACK_DEPTH          'GL_ATTRIB_STACK_DEPTH          export
2993 -->constant GL_CLIENT_ATTRIB_STACK_DEPTH   'GL_CLIENT_ATTRIB_STACK_DEPTH   export
3106 -->constant GL_COLOR_CLEAR_VALUE           'GL_COLOR_CLEAR_VALUE           export
3107 -->constant GL_COLOR_WRITEMASK             'GL_COLOR_WRITEMASK             export
2817 -->constant GL_CURRENT_INDEX               'GL_CURRENT_INDEX               export
2816 -->constant GL_CURRENT_COLOR               'GL_CURRENT_COLOR               export
2818 -->constant GL_CURRENT_NORMAL              'GL_CURRENT_NORMAL              export
2820 -->constant GL_CURRENT_RASTER_COLOR        'GL_CURRENT_RASTER_COLOR        export
2825 -->constant GL_CURRENT_RASTER_DISTANCE     'GL_CURRENT_RASTER_DISTANCE     export
2821 -->constant GL_CURRENT_RASTER_INDEX        'GL_CURRENT_RASTER_INDEX        export
2823 -->constant GL_CURRENT_RASTER_POSITION     'GL_CURRENT_RASTER_POSITION     export
2822 -->constant GL_CURRENT_RASTER_TEXTURE_COORDS       'GL_CURRENT_RASTER_TEXTURE_COORDS       export
2824 -->constant GL_CURRENT_RASTER_POSITION_VALID       'GL_CURRENT_RASTER_POSITION_VALID       export
2819 -->constant GL_CURRENT_TEXTURE_COORDS      'GL_CURRENT_TEXTURE_COORDS      export
3104 -->constant GL_INDEX_CLEAR_VALUE           'GL_INDEX_CLEAR_VALUE           export
3120 -->constant GL_INDEX_MODE                  'GL_INDEX_MODE                  export
3105 -->constant GL_INDEX_WRITEMASK             'GL_INDEX_WRITEMASK             export
2982 -->constant GL_MODELVIEW_MATRIX            'GL_MODELVIEW_MATRIX            export
2979 -->constant GL_MODELVIEW_STACK_DEPTH       'GL_MODELVIEW_STACK_DEPTH       export
3440 -->constant GL_NAME_STACK_DEPTH            'GL_NAME_STACK_DEPTH            export
2983 -->constant GL_PROJECTION_MATRIX           'GL_PROJECTION_MATRIX           export
2980 -->constant GL_PROJECTION_STACK_DEPTH      'GL_PROJECTION_STACK_DEPTH      export
3136 -->constant GL_RENDER_MODE                 'GL_RENDER_MODE                 export
3121 -->constant GL_RGBA_MODE                   'GL_RGBA_MODE                   export
2984 -->constant GL_TEXTURE_MATRIX              'GL_TEXTURE_MATRIX              export
2981 -->constant GL_TEXTURE_STACK_DEPTH         'GL_TEXTURE_STACK_DEPTH         export
2978 -->constant GL_VIEWPORT                    'GL_VIEWPORT                    export


( Evaluators: )
3456 -->constant GL_AUTO_NORMAL                 'GL_AUTO_NORMAL                 export
3472 -->constant GL_MAP1_COLOR_4                'GL_MAP1_COLOR_4                export
3536 -->constant GL_MAP1_GRID_DOMAIN            'GL_MAP1_GRID_DOMAIN            export
3537 -->constant GL_MAP1_GRID_SEGMENTS          'GL_MAP1_GRID_SEGMENTS          export
3473 -->constant GL_MAP1_INDEX                  'GL_MAP1_INDEX                  export
3474 -->constant GL_MAP1_NORMAL                 'GL_MAP1_NORMAL                 export
3475 -->constant GL_MAP1_TEXTURE_COORD_1        'GL_MAP1_TEXTURE_COORD_1        export
3476 -->constant GL_MAP1_TEXTURE_COORD_2        'GL_MAP1_TEXTURE_COORD_2        export
3477 -->constant GL_MAP1_TEXTURE_COORD_3        'GL_MAP1_TEXTURE_COORD_3        export
3478 -->constant GL_MAP1_TEXTURE_COORD_4        'GL_MAP1_TEXTURE_COORD_4        export
3479 -->constant GL_MAP1_VERTEX_3               'GL_MAP1_VERTEX_3               export
3480 -->constant GL_MAP1_VERTEX_4               'GL_MAP1_VERTEX_4               export
3504 -->constant GL_MAP2_COLOR_4                'GL_MAP2_COLOR_4                export
3538 -->constant GL_MAP2_GRID_DOMAIN            'GL_MAP2_GRID_DOMAIN            export
3539 -->constant GL_MAP2_GRID_SEGMENTS          'GL_MAP2_GRID_SEGMENTS          export
3505 -->constant GL_MAP2_INDEX                  'GL_MAP2_INDEX                  export
3506 -->constant GL_MAP2_NORMAL                 'GL_MAP2_NORMAL                 export
3507 -->constant GL_MAP2_TEXTURE_COORD_1        'GL_MAP2_TEXTURE_COORD_1        export
3508 -->constant GL_MAP2_TEXTURE_COORD_2        'GL_MAP2_TEXTURE_COORD_2        export
3509 -->constant GL_MAP2_TEXTURE_COORD_3        'GL_MAP2_TEXTURE_COORD_3        export
3510 -->constant GL_MAP2_TEXTURE_COORD_4        'GL_MAP2_TEXTURE_COORD_4        export
3511 -->constant GL_MAP2_VERTEX_3               'GL_MAP2_VERTEX_3               export
3512 -->constant GL_MAP2_VERTEX_4               'GL_MAP2_VERTEX_4               export
2560 -->constant GL_COEFF                       'GL_COEFF                       export
2562 -->constant GL_DOMAIN                      'GL_DOMAIN                      export
2561 -->constant GL_ORDER                       'GL_ORDER                       export

( Hints: )
3156 -->constant GL_FOG_HINT                    'GL_FOG_HINT                    export
3154 -->constant GL_LINE_SMOOTH_HINT            'GL_LINE_SMOOTH_HINT            export
3152 -->constant GL_PERSPECTIVE_CORRECTION_HINT 'GL_PERSPECTIVE_CORRECTION_HINT export
3153 -->constant GL_POINT_SMOOTH_HINT           'GL_POINT_SMOOTH_HINT           export
3155 -->constant GL_POLYGON_SMOOTH_HINT         'GL_POLYGON_SMOOTH_HINT         export
4352 -->constant GL_DONT_CARE                   'GL_DONT_CARE                   export
4353 -->constant GL_FASTEST                     'GL_FASTEST                     export
4354 -->constant GL_NICEST                      'GL_NICEST                      export

( Scissor box: )
3089 -->constant GL_SCISSOR_TEST                'GL_SCISSOR_TEST                export
3088 -->constant GL_SCISSOR_BOX                 'GL_SCISSOR_BOX                 export

( Pixel Mode / Transfer: )
3344 -->constant GL_MAP_COLOR                   'GL_MAP_COLOR                   export
3345 -->constant GL_MAP_STENCIL                 'GL_MAP_STENCIL                 export
3346 -->constant GL_INDEX_SHIFT                 'GL_INDEX_SHIFT                 export
3347 -->constant GL_INDEX_OFFSET                'GL_INDEX_OFFSET                export
3348 -->constant GL_RED_SCALE                   'GL_RED_SCALE                   export
3349 -->constant GL_RED_BIAS                    'GL_RED_BIAS                    export
3352 -->constant GL_GREEN_SCALE                 'GL_GREEN_SCALE                 export
3353 -->constant GL_GREEN_BIAS                  'GL_GREEN_BIAS                  export
3354 -->constant GL_BLUE_SCALE                  'GL_BLUE_SCALE                  export
3355 -->constant GL_BLUE_BIAS                   'GL_BLUE_BIAS                   export
3356 -->constant GL_ALPHA_SCALE                 'GL_ALPHA_SCALE                 export
3357 -->constant GL_ALPHA_BIAS                  'GL_ALPHA_BIAS                  export
3358 -->constant GL_DEPTH_SCALE                 'GL_DEPTH_SCALE                 export
3359 -->constant GL_DEPTH_BIAS                  'GL_DEPTH_BIAS                  export
3249 -->constant GL_PIXEL_MAP_S_TO_S_SIZE       'GL_PIXEL_MAP_S_TO_S_SIZE       export
3248 -->constant GL_PIXEL_MAP_I_TO_I_SIZE       'GL_PIXEL_MAP_I_TO_I_SIZE       export
3250 -->constant GL_PIXEL_MAP_I_TO_R_SIZE       'GL_PIXEL_MAP_I_TO_R_SIZE       export
3251 -->constant GL_PIXEL_MAP_I_TO_G_SIZE       'GL_PIXEL_MAP_I_TO_G_SIZE       export
3252 -->constant GL_PIXEL_MAP_I_TO_B_SIZE       'GL_PIXEL_MAP_I_TO_B_SIZE       export
3253 -->constant GL_PIXEL_MAP_I_TO_A_SIZE       'GL_PIXEL_MAP_I_TO_A_SIZE       export
3254 -->constant GL_PIXEL_MAP_R_TO_R_SIZE       'GL_PIXEL_MAP_R_TO_R_SIZE       export
3255 -->constant GL_PIXEL_MAP_G_TO_G_SIZE       'GL_PIXEL_MAP_G_TO_G_SIZE       export
3256 -->constant GL_PIXEL_MAP_B_TO_B_SIZE       'GL_PIXEL_MAP_B_TO_B_SIZE       export
3257 -->constant GL_PIXEL_MAP_A_TO_A_SIZE       'GL_PIXEL_MAP_A_TO_A_SIZE       export
3185 -->constant GL_PIXEL_MAP_S_TO_S            'GL_PIXEL_MAP_S_TO_S            export
3184 -->constant GL_PIXEL_MAP_I_TO_I            'GL_PIXEL_MAP_I_TO_I            export
3186 -->constant GL_PIXEL_MAP_I_TO_R            'GL_PIXEL_MAP_I_TO_R            export
3187 -->constant GL_PIXEL_MAP_I_TO_G            'GL_PIXEL_MAP_I_TO_G            export
3188 -->constant GL_PIXEL_MAP_I_TO_B            'GL_PIXEL_MAP_I_TO_B            export
3189 -->constant GL_PIXEL_MAP_I_TO_A            'GL_PIXEL_MAP_I_TO_A            export
3190 -->constant GL_PIXEL_MAP_R_TO_R            'GL_PIXEL_MAP_R_TO_R            export
3191 -->constant GL_PIXEL_MAP_G_TO_G            'GL_PIXEL_MAP_G_TO_G            export
3192 -->constant GL_PIXEL_MAP_B_TO_B            'GL_PIXEL_MAP_B_TO_B            export
3193 -->constant GL_PIXEL_MAP_A_TO_A            'GL_PIXEL_MAP_A_TO_A            export
3333 -->constant GL_PACK_ALIGNMENT              'GL_PACK_ALIGNMENT              export
3329 -->constant GL_PACK_LSB_FIRST              'GL_PACK_LSB_FIRST              export
3330 -->constant GL_PACK_ROW_LENGTH             'GL_PACK_ROW_LENGTH             export
3332 -->constant GL_PACK_SKIP_PIXELS            'GL_PACK_SKIP_PIXELS            export
3331 -->constant GL_PACK_SKIP_ROWS              'GL_PACK_SKIP_ROWS              export
3328 -->constant GL_PACK_SWAP_BYTES             'GL_PACK_SWAP_BYTES             export
3317 -->constant GL_UNPACK_ALIGNMENT            'GL_UNPACK_ALIGNMENT            export
3313 -->constant GL_UNPACK_LSB_FIRST            'GL_UNPACK_LSB_FIRST            export
3314 -->constant GL_UNPACK_ROW_LENGTH           'GL_UNPACK_ROW_LENGTH           export
3316 -->constant GL_UNPACK_SKIP_PIXELS          'GL_UNPACK_SKIP_PIXELS          export
3315 -->constant GL_UNPACK_SKIP_ROWS            'GL_UNPACK_SKIP_ROWS            export
3312 -->constant GL_UNPACK_SWAP_BYTES           'GL_UNPACK_SWAP_BYTES           export
3350 -->constant GL_ZOOM_X                      'GL_ZOOM_X                      export
3351 -->constant GL_ZOOM_Y                      'GL_ZOOM_Y                      export

( Texture mapping: )
8960  -->constant GL_TEXTURE_ENV                'GL_TEXTURE_ENV                 export
8704  -->constant GL_TEXTURE_ENV_MODE           'GL_TEXTURE_ENV_MODE            export
3552  -->constant GL_TEXTURE_1D                 'GL_TEXTURE_1D                  export
3553  -->constant GL_TEXTURE_2D                 'GL_TEXTURE_2D                  export
10242 -->constant GL_TEXTURE_WRAP_S             'GL_TEXTURE_WRAP_S              export
10243 -->constant GL_TEXTURE_WRAP_T             'GL_TEXTURE_WRAP_T              export
10240 -->constant GL_TEXTURE_MAG_FILTER         'GL_TEXTURE_MAG_FILTER          export
10241 -->constant GL_TEXTURE_MIN_FILTER         'GL_TEXTURE_MIN_FILTER          export
8705  -->constant GL_TEXTURE_ENV_COLOR          'GL_TEXTURE_ENV_COLOR           export
3168  -->constant GL_TEXTURE_GEN_S              'GL_TEXTURE_GEN_S               export
3169  -->constant GL_TEXTURE_GEN_T              'GL_TEXTURE_GEN_T               export
9472  -->constant GL_TEXTURE_GEN_MODE           'GL_TEXTURE_GEN_MODE            export
4100  -->constant GL_TEXTURE_BORDER_COLOR       'GL_TEXTURE_BORDER_COLOR        export
4096  -->constant GL_TEXTURE_WIDTH              'GL_TEXTURE_WIDTH               export
4097  -->constant GL_TEXTURE_HEIGHT             'GL_TEXTURE_HEIGHT              export
4101  -->constant GL_TEXTURE_BORDER             'GL_TEXTURE_BORDER              export
4099  -->constant GL_TEXTURE_COMPONENTS         'GL_TEXTURE_COMPONENTS          export
32860 -->constant GL_TEXTURE_RED_SIZE           'GL_TEXTURE_RED_SIZE            export
32861 -->constant GL_TEXTURE_GREEN_SIZE         'GL_TEXTURE_GREEN_SIZE          export
32862 -->constant GL_TEXTURE_BLUE_SIZE          'GL_TEXTURE_BLUE_SIZE           export
32863 -->constant GL_TEXTURE_ALPHA_SIZE         'GL_TEXTURE_ALPHA_SIZE          export
32864 -->constant GL_TEXTURE_LUMINANCE_SIZE     'GL_TEXTURE_LUMINANCE_SIZE      export
32865 -->constant GL_TEXTURE_INTENSITY_SIZE     'GL_TEXTURE_INTENSITY_SIZE      export
9984  -->constant GL_NEAREST_MIPMAP_NEAREST     'GL_NEAREST_MIPMAP_NEAREST      export
9986  -->constant GL_NEAREST_MIPMAP_LINEAR      'GL_NEAREST_MIPMAP_LINEAR       export
9985  -->constant GL_LINEAR_MIPMAP_NEAREST      'GL_LINEAR_MIPMAP_NEAREST       export
9987  -->constant GL_LINEAR_MIPMAP_LINEAR       'GL_LINEAR_MIPMAP_LINEAR        export
9217  -->constant GL_OBJECT_LINEAR              'GL_OBJECT_LINEAR               export
9473  -->constant GL_OBJECT_PLANE               'GL_OBJECT_PLANE                export
9216  -->constant GL_EYE_LINEAR                 'GL_EYE_LINEAR                  export
9474  -->constant GL_EYE_PLANE                  'GL_EYE_PLANE                   export
9218  -->constant GL_SPHERE_MAP                 'GL_SPHERE_MAP                  export
8449  -->constant GL_DECAL                      'GL_DECAL                       export
8448  -->constant GL_MODULATE                   'GL_MODULATE                    export
9728  -->constant GL_NEAREST                    'GL_NEAREST                     export
10497 -->constant GL_REPEAT                     'GL_REPEAT                      export
10496 -->constant GL_CLAMP                      'GL_CLAMP                       export
8192  -->constant GL_S                          'GL_S                           export
8193  -->constant GL_T                          'GL_T                           export
8194  -->constant GL_R                          'GL_R                           export
8195  -->constant GL_Q                          'GL_Q                           export
3170  -->constant GL_TEXTURE_GEN_R              'GL_TEXTURE_GEN_R               export
3171  -->constant GL_TEXTURE_GEN_Q              'GL_TEXTURE_GEN_Q               export

( GL 1.1 texturing: )
32867 -->constant GL_PROXY_TEXTURE_1D           'GL_PROXY_TEXTURE_1D            export
32868 -->constant GL_PROXY_TEXTURE_2D           'GL_PROXY_TEXTURE_2D            export
32870 -->constant GL_TEXTURE_PRIORITY           'GL_TEXTURE_PRIORITY            export
32871 -->constant GL_TEXTURE_RESIDENT           'GL_TEXTURE_RESIDENT            export
32872 -->constant GL_TEXTURE_BINDING_1D         'GL_TEXTURE_BINDING_1D          export
32873 -->constant GL_TEXTURE_BINDING_2D         'GL_TEXTURE_BINDING_2D          export
4099  -->constant GL_TEXTURE_INTERNAL_FORMAT    'GL_TEXTURE_INTERNAL_FORMAT     export

( GL 1.2 texturing: )
32875 -->constant GL_PACK_SKIP_IMAGES           'GL_PACK_SKIP_IMAGES            export
32876 -->constant GL_PACK_IMAGE_HEIGHT          'GL_PACK_IMAGE_HEIGHT           export
32877 -->constant GL_UNPACK_SKIP_IMAGES         'GL_UNPACK_SKIP_IMAGES          export
32878 -->constant GL_UNPACK_IMAGE_HEIGHT        'GL_UNPACK_IMAGE_HEIGHT         export
32879 -->constant GL_TEXTURE_3D                 'GL_TEXTURE_3D                  export
32880 -->constant GL_PROXY_TEXTURE_3D           'GL_PROXY_TEXTURE_3D            export
32881 -->constant GL_TEXTURE_DEPTH              'GL_TEXTURE_DEPTH               export
32882 -->constant GL_TEXTURE_WRAP_R             'GL_TEXTURE_WRAP_R              export
32883 -->constant GL_MAX_3D_TEXTURE_SIZE        'GL_MAX_3D_TEXTURE_SIZE         export
32874 -->constant GL_TEXTURE_BINDING_3D         'GL_TEXTURE_BINDING_3D          export
        
        ( Internal texture formats  -- GL 1.1: )
32827 -->constant GL_ALPHA4                     'GL_ALPHA4                      export
32828 -->constant GL_ALPHA8                     'GL_ALPHA8                      export
32829 -->constant GL_ALPHA12                    'GL_ALPHA12                     export
32830 -->constant GL_ALPHA16                    'GL_ALPHA16                     export
32831 -->constant GL_LUMINANCE4                 'GL_LUMINANCE4                  export
32832 -->constant GL_LUMINANCE8                 'GL_LUMINANCE8                  export
32833 -->constant GL_LUMINANCE12                'GL_LUMINANCE12                 export
32834 -->constant GL_LUMINANCE16                'GL_LUMINANCE16                 export
32835 -->constant GL_LUMINANCE4_ALPHA4          'GL_LUMINANCE4_ALPHA4           export
32836 -->constant GL_LUMINANCE6_ALPHA2          'GL_LUMINANCE6_ALPHA2           export
32837 -->constant GL_LUMINANCE8_ALPHA8          'GL_LUMINANCE8_ALPHA8           export
32838 -->constant GL_LUMINANCE12_ALPHA4         'GL_LUMINANCE12_ALPHA4          export
32839 -->constant GL_LUMINANCE12_ALPHA12        'GL_LUMINANCE12_ALPHA12         export
32840 -->constant GL_LUMINANCE16_ALPHA16        'GL_LUMINANCE16_ALPHA16         export
32841 -->constant GL_INTENSITY                  'GL_INTENSITY                   export
32842 -->constant GL_INTENSITY4                 'GL_INTENSITY4                  export
32843 -->constant GL_INTENSITY8                 'GL_INTENSITY8                  export
32844 -->constant GL_INTENSITY12                'GL_INTENSITY12                 export
32845 -->constant GL_INTENSITY16                'GL_INTENSITY16                 export
10768 -->constant GL_R3_G3_B2                   'GL_R3_G3_B2                    export
32847 -->constant GL_RGB4                       'GL_RGB4                        export
32848 -->constant GL_RGB5                       'GL_RGB5                        export
32849 -->constant GL_RGB8                       'GL_RGB8                        export
32850 -->constant GL_RGB10                      'GL_RGB10                       export
32851 -->constant GL_RGB12                      'GL_RGB12                       export
32852 -->constant GL_RGB16                      'GL_RGB16                       export
32853 -->constant GL_RGBA2                      'GL_RGBA2                       export
32854 -->constant GL_RGBA4                      'GL_RGBA4                       export
32855 -->constant GL_RGB5_A1                    'GL_RGB5_A1                     export
32856 -->constant GL_RGBA8                      'GL_RGBA8                       export
32857 -->constant GL_RGB10_A2                   'GL_RGB10_A2                    export
32858 -->constant GL_RGBA12                     'GL_RGBA12                      export
32859 -->constant GL_RGBA16                     'GL_RGBA16                      export
        
( Utility: )
7936 -->constant GL_VENDOR                      'GL_VENDOR                      export
7937 -->constant GL_RENDERER                    'GL_RENDERER                    export
7938 -->constant GL_VERSION                     'GL_VERSION                     export
7939 -->constant GL_EXTENSIONS                  'GL_EXTENSIONS                  export

( Errors: )
1281 -->constant GL_INVALID_VALUE               'GL_INVALID_VALUE               export
1280 -->constant GL_INVALID_ENUM                'GL_INVALID_ENUM                export
1282 -->constant GL_INVALID_OPERATION           'GL_INVALID_OPERATION           export
1283 -->constant GL_STACK_OVERFLOW              'GL_STACK_OVERFLOW              export
1284 -->constant GL_STACK_UNDERFLOW             'GL_STACK_UNDERFLOW             export
1285 -->constant GL_OUT_OF_MEMORY               'GL_OUT_OF_MEMORY               export
        
( Extensions: )

( GL_EXT_blend_minmax and GL_EXT_blend_color: )
32769 -->constant GL_CONSTANT_COLOR_EXT                 'GL_CONSTANT_COLOR_EXT          export
32770 -->constant GL_ONE_MINUS_CONSTANT_COLOR_EXT       'GL_ONE_MINUS_CONSTANT_COLOR_EXT        export
32771 -->constant GL_CONSTANT_ALPHA_EXT                 'GL_CONSTANT_ALPHA_EXT          export
32772 -->constant GL_ONE_MINUS_CONSTANT_ALPHA_EXT       'GL_ONE_MINUS_CONSTANT_ALPHA_EXT        export
32777 -->constant GL_BLEND_EQUATION_EXT                 'GL_BLEND_EQUATION_EXT          export
32775 -->constant GL_MIN_EXT                            'GL_MIN_EXT                     export
32776 -->constant GL_MAX_EXT                            'GL_MAX_EXT                     export
32774 -->constant GL_FUNC_ADD_EXT                       'GL_FUNC_ADD_EXT                export
32778 -->constant GL_FUNC_SUBTRACT_EXT                  'GL_FUNC_SUBTRACT_EXT           export
32779 -->constant GL_FUNC_REVERSE_SUBTRACT_EXT          'GL_FUNC_REVERSE_SUBTRACT_EXT   export
32773 -->constant GL_BLEND_COLOR_EXT                    'GL_BLEND_COLOR_EXT             export
        
( GL_EXT_polygon_offset: )
32823 -->constant GL_POLYGON_OFFSET_EXT                 'GL_POLYGON_OFFSET_EXT          export
32824 -->constant GL_POLYGON_OFFSET_FACTOR_EXT          'GL_POLYGON_OFFSET_FACTOR_EXT   export
32825 -->constant GL_POLYGON_OFFSET_BIAS_EXT            'GL_POLYGON_OFFSET_BIAS_EXT     export

( GL_EXT_vertex_array: )
32884 -->constant GL_VERTEX_ARRAY_EXT                   'GL_VERTEX_ARRAY_EXT            export
32885 -->constant GL_NORMAL_ARRAY_EXT                   'GL_NORMAL_ARRAY_EXT            export
32886 -->constant GL_COLOR_ARRAY_EXT                    'GL_COLOR_ARRAY_EXT             export
32887 -->constant GL_INDEX_ARRAY_EXT                    'GL_INDEX_ARRAY_EXT             export
32888 -->constant GL_TEXTURE_COORD_ARRAY_EXT            'GL_TEXTURE_COORD_ARRAY_EXT     export
32889 -->constant GL_EDGE_FLAG_ARRAY_EXT                'GL_EDGE_FLAG_ARRAY_EXT         export
32890 -->constant GL_VERTEX_ARRAY_SIZE_EXT              'GL_VERTEX_ARRAY_SIZE_EXT       export
32891 -->constant GL_VERTEX_ARRAY_TYPE_EXT              'GL_VERTEX_ARRAY_TYPE_EXT       export
32892 -->constant GL_VERTEX_ARRAY_STRIDE_EXT            'GL_VERTEX_ARRAY_STRIDE_EXT     export
32893 -->constant GL_VERTEX_ARRAY_COUNT_EXT             'GL_VERTEX_ARRAY_COUNT_EXT      export
32894 -->constant GL_NORMAL_ARRAY_TYPE_EXT              'GL_NORMAL_ARRAY_TYPE_EXT       export
32895 -->constant GL_NORMAL_ARRAY_STRIDE_EXT            'GL_NORMAL_ARRAY_STRIDE_EXT     export
32896 -->constant GL_NORMAL_ARRAY_COUNT_EXT             'GL_NORMAL_ARRAY_COUNT_EXT      export
32897 -->constant GL_COLOR_ARRAY_SIZE_EXT               'GL_COLOR_ARRAY_SIZE_EXT        export
32898 -->constant GL_COLOR_ARRAY_TYPE_EXT               'GL_COLOR_ARRAY_TYPE_EXT        export
32899 -->constant GL_COLOR_ARRAY_STRIDE_EXT             'GL_COLOR_ARRAY_STRIDE_EXT      export
32900 -->constant GL_COLOR_ARRAY_COUNT_EXT              'GL_COLOR_ARRAY_COUNT_EXT       export
32901 -->constant GL_INDEX_ARRAY_TYPE_EXT               'GL_INDEX_ARRAY_TYPE_EXT        export
32902 -->constant GL_INDEX_ARRAY_STRIDE_EXT             'GL_INDEX_ARRAY_STRIDE_EXT      export
32903 -->constant GL_INDEX_ARRAY_COUNT_EXT              'GL_INDEX_ARRAY_COUNT_EXT       export
32904 -->constant GL_TEXTURE_COORD_ARRAY_SIZE_EXT       'GL_TEXTURE_COORD_ARRAY_SIZE_EXT        export
32905 -->constant GL_TEXTURE_COORD_ARRAY_TYPE_EXT       'GL_TEXTURE_COORD_ARRAY_TYPE_EXT        export
32906 -->constant GL_TEXTURE_COORD_ARRAY_STRIDE_EXT     'GL_TEXTURE_COORD_ARRAY_STRIDE_EXT      export
32907 -->constant GL_TEXTURE_COORD_ARRAY_COUNT_EXT      'GL_TEXTURE_COORD_ARRAY_COUNT_EXT       export
32908 -->constant GL_EDGE_FLAG_ARRAY_STRIDE_EXT         'GL_EDGE_FLAG_ARRAY_STRIDE_EXT  export
32909 -->constant GL_EDGE_FLAG_ARRAY_COUNT_EXT          'GL_EDGE_FLAG_ARRAY_COUNT_EXT   export
32910 -->constant GL_VERTEX_ARRAY_POINTER_EXT           'GL_VERTEX_ARRAY_POINTER_EXT    export
32911 -->constant GL_NORMAL_ARRAY_POINTER_EXT           'GL_NORMAL_ARRAY_POINTER_EXT    export
32912 -->constant GL_COLOR_ARRAY_POINTER_EXT            'GL_COLOR_ARRAY_POINTER_EXT     export
32913 -->constant GL_INDEX_ARRAY_POINTER_EXT            'GL_INDEX_ARRAY_POINTER_EXT     export
32914 -->constant GL_TEXTURE_COORD_ARRAY_POINTER_EXT    'GL_TEXTURE_COORD_ARRAY_POINTER_EXT     export
32915 -->constant GL_EDGE_FLAG_ARRAY_POINTER_EXT        'GL_EDGE_FLAG_ARRAY_POINTER_EXT export

( GL_EXT_texture_object: )
32870 -->constant GL_TEXTURE_PRIORITY_EXT               'GL_TEXTURE_PRIORITY_EXT        export
32871 -->constant GL_TEXTURE_RESIDENT_EXT               'GL_TEXTURE_RESIDENT_EXT        export
32872 -->constant GL_TEXTURE_1D_BINDING_EXT             'GL_TEXTURE_1D_BINDING_EXT      export
32873 -->constant GL_TEXTURE_2D_BINDING_EXT             'GL_TEXTURE_2D_BINDING_EXT      export

( GL_EXT_texture3D: )
32875 -->constant GL_PACK_SKIP_IMAGES_EXT               'GL_PACK_SKIP_IMAGES_EXT        export
32876 -->constant GL_PACK_IMAGE_HEIGHT_EXT              'GL_PACK_IMAGE_HEIGHT_EXT       export
32877 -->constant GL_UNPACK_SKIP_IMAGES_EXT             'GL_UNPACK_SKIP_IMAGES_EXT      export
32878 -->constant GL_UNPACK_IMAGE_HEIGHT_EXT            'GL_UNPACK_IMAGE_HEIGHT_EXT     export
32879 -->constant GL_TEXTURE_3D_EXT                     'GL_TEXTURE_3D_EXT              export
32880 -->constant GL_PROXY_TEXTURE_3D_EXT               'GL_PROXY_TEXTURE_3D_EXT        export
32881 -->constant GL_TEXTURE_DEPTH_EXT                  'GL_TEXTURE_DEPTH_EXT           export
32882 -->constant GL_TEXTURE_WRAP_R_EXT                 'GL_TEXTURE_WRAP_R_EXT          export
32883 -->constant GL_MAX_3D_TEXTURE_SIZE_EXT            'GL_MAX_3D_TEXTURE_SIZE_EXT     export
32874 -->constant GL_TEXTURE_3D_BINDING_EXT             'GL_TEXTURE_3D_BINDING_EXT      export

( GL_EXT_paletted_texture: )
32817 -->constant GL_TABLE_TOO_LARGE_EXT                'GL_TABLE_TOO_LARGE_EXT         export
32984 -->constant GL_COLOR_TABLE_FORMAT_EXT             'GL_COLOR_TABLE_FORMAT_EXT      export
32985 -->constant GL_COLOR_TABLE_WIDTH_EXT              'GL_COLOR_TABLE_WIDTH_EXT       export
32986 -->constant GL_COLOR_TABLE_RED_SIZE_EXT           'GL_COLOR_TABLE_RED_SIZE_EXT    export
32987 -->constant GL_COLOR_TABLE_GREEN_SIZE_EXT         'GL_COLOR_TABLE_GREEN_SIZE_EXT  export
32988 -->constant GL_COLOR_TABLE_BLUE_SIZE_EXT          'GL_COLOR_TABLE_BLUE_SIZE_EXT   export
32989 -->constant GL_COLOR_TABLE_ALPHA_SIZE_EXT         'GL_COLOR_TABLE_ALPHA_SIZE_EXT  export
32990 -->constant GL_COLOR_TABLE_LUMINANCE_SIZE_EXT     'GL_COLOR_TABLE_LUMINANCE_SIZE_EXT      export
32991 -->constant GL_COLOR_TABLE_INTENSITY_SIZE_EXT     'GL_COLOR_TABLE_INTENSITY_SIZE_EXT      export
33005 -->constant GL_TEXTURE_INDEX_SIZE_EXT             'GL_TEXTURE_INDEX_SIZE_EXT      export
32994 -->constant GL_COLOR_INDEX1_EXT                   'GL_COLOR_INDEX1_EXT            export
32995 -->constant GL_COLOR_INDEX2_EXT                   'GL_COLOR_INDEX2_EXT            export
32996 -->constant GL_COLOR_INDEX4_EXT                   'GL_COLOR_INDEX4_EXT            export
32997 -->constant GL_COLOR_INDEX8_EXT                   'GL_COLOR_INDEX8_EXT            export
32998 -->constant GL_COLOR_INDEX12_EXT                  'GL_COLOR_INDEX12_EXT           export
32999 -->constant GL_COLOR_INDEX16_EXT                  'GL_COLOR_INDEX16_EXT           export

( GL_EXT_shared_texture_palette: )
33275 -->constant GL_SHARED_TEXTURE_PALETTE_EXT         'GL_SHARED_TEXTURE_PALETTE_EXT  export

( GL_EXT_point_parameters: )
33062 -->constant GL_POINT_SIZE_MIN_EXT                 'GL_POINT_SIZE_MIN_EXT          export
33063 -->constant GL_POINT_SIZE_MAX_EXT                 'GL_POINT_SIZE_MAX_EXT          export
33064 -->constant GL_POINT_FADE_THRESHOLD_SIZE_EXT      'GL_POINT_FADE_THRESHOLD_SIZE_EXT       export
33065 -->constant GL_DISTANCE_ATTENUATION_EXT           'GL_DISTANCE_ATTENUATION_EXT    export

( GL_EXT_rescale_normal: )
32826 -->constant GL_RESCALE_NORMAL_EXT                 'GL_RESCALE_NORMAL_EXT          export

( GL_EXT_abgr: )
32768 -->constant GL_ABGR_EXT                           'GL_ABGR_EXT                    export

( GL_SGIS_multitexture: )
33628 -->constant GL_SELECTED_TEXTURE_SGIS              'GL_SELECTED_TEXTURE_SGIS       export
33629 -->constant GL_SELECTED_TEXTURE_COORD_SET_SGIS    'GL_SELECTED_TEXTURE_COORD_SET_SGIS     export
33630 -->constant GL_MAX_TEXTURES_SGIS                  'GL_MAX_TEXTURES_SGIS           export
33631 -->constant GL_TEXTURE0_SGIS                      'GL_TEXTURE0_SGIS               export
33632 -->constant GL_TEXTURE1_SGIS                      'GL_TEXTURE1_SGIS               export
33633 -->constant GL_TEXTURE2_SGIS                      'GL_TEXTURE2_SGIS               export
33634 -->constant GL_TEXTURE3_SGIS                      'GL_TEXTURE3_SGIS               export
33635 -->constant GL_TEXTURE_COORD_SET_SOURCE_SGIS      'GL_TEXTURE_COORD_SET_SOURCE_SGIS       export

( GL_EXT_multitexture: )
33728 -->constant GL_SELECTED_TEXTURE_EXT               'GL_SELECTED_TEXTURE_EXT        export
33729 -->constant GL_SELECTED_TEXTURE_COORD_SET_EXT     'GL_SELECTED_TEXTURE_COORD_SET_EXT      export
33730 -->constant GL_SELECTED_TEXTURE_TRANSFORM_EXT     'GL_SELECTED_TEXTURE_TRANSFORM_EXT      export
33731 -->constant GL_MAX_TEXTURES_EXT                   'GL_MAX_TEXTURES_EXT            export
33732 -->constant GL_MAX_TEXTURE_COORD_SETS_EXT         'GL_MAX_TEXTURE_COORD_SETS_EXT  export
33733 -->constant GL_TEXTURE_ENV_COORD_SET_EXT          'GL_TEXTURE_ENV_COORD_SET_EXT   export
33734 -->constant GL_TEXTURE0_EXT                       'GL_TEXTURE0_EXT                export
33735 -->constant GL_TEXTURE1_EXT                       'GL_TEXTURE1_EXT                export
33736 -->constant GL_TEXTURE2_EXT                       'GL_TEXTURE2_EXT                export
33737 -->constant GL_TEXTURE3_EXT                       'GL_TEXTURE3_EXT                export

( GL_SGIS_texture_edge_clamp: )
33071 -->constant GL_CLAMP_TO_EDGE_SGIS                 'GL_CLAMP_TO_EDGE_SGIS          export

( OpenGL 1.2: )
32826 -->constant GL_RESCALE_NORMAL                     'GL_RESCALE_NORMAL              export
33071 -->constant GL_CLAMP_TO_EDGE                      'GL_CLAMP_TO_EDGE               export
61672 -->constant GL_MAX_ELEMENTS_VERTICES              'GL_MAX_ELEMENTS_VERTICES       export
61673 -->constant GL_MAX_ELEMENTS_INDICES               'GL_MAX_ELEMENTS_INDICES        export
32992 -->constant GL_BGR                                'GL_BGR                         export
32993 -->constant GL_BGRA                               'GL_BGRA                        export
32818 -->constant GL_UNSIGNED_BYTE_3_3_2                'GL_UNSIGNED_BYTE_3_3_2         export
33634 -->constant GL_UNSIGNED_BYTE_2_3_3_REV            'GL_UNSIGNED_BYTE_2_3_3_REV     export
33635 -->constant GL_UNSIGNED_SHORT_5_6_5               'GL_UNSIGNED_SHORT_5_6_5        export
33636 -->constant GL_UNSIGNED_SHORT_5_6_5_REV           'GL_UNSIGNED_SHORT_5_6_5_REV    export
32819 -->constant GL_UNSIGNED_SHORT_4_4_4_4             'GL_UNSIGNED_SHORT_4_4_4_4      export
33637 -->constant GL_UNSIGNED_SHORT_4_4_4_4_REV         'GL_UNSIGNED_SHORT_4_4_4_4_REV  export
32820 -->constant GL_UNSIGNED_SHORT_5_5_5_1             'GL_UNSIGNED_SHORT_5_5_5_1      export
33638 -->constant GL_UNSIGNED_SHORT_1_5_5_5_REV         'GL_UNSIGNED_SHORT_1_5_5_5_REV  export
32821 -->constant GL_UNSIGNED_INT_8_8_8_8               'GL_UNSIGNED_INT_8_8_8_8        export
33639 -->constant GL_UNSIGNED_INT_8_8_8_8_REV           'GL_UNSIGNED_INT_8_8_8_8_REV    export
32822 -->constant GL_UNSIGNED_INT_10_10_10_2            'GL_UNSIGNED_INT_10_10_10_2     export
33640 -->constant GL_UNSIGNED_INT_2_10_10_10_REV        'GL_UNSIGNED_INT_2_10_10_10_REV export
33272 -->constant GL_LIGHT_MODEL_COLOR_CONTROL          'GL_LIGHT_MODEL_COLOR_CONTROL   export
33273 -->constant GL_SINGLE_COLOR                       'GL_SINGLE_COLOR                export
33274 -->constant GL_SEPARATE_SPECULAR_COLOR            'GL_SEPARATE_SPECULAR_COLOR     export
33082 -->constant GL_TEXTURE_MIN_LOD                    'GL_TEXTURE_MIN_LOD             export
33083 -->constant GL_TEXTURE_MAX_LOD                    'GL_TEXTURE_MAX_LOD             export
33084 -->constant GL_TEXTURE_BASE_LEVEL                 'GL_TEXTURE_BASE_LEVEL          export
33085 -->constant GL_TEXTURE_MAX_LEVEL                  'GL_TEXTURE_MAX_LEVEL           export

1       -->constant GL_CURRENT_BIT                      'GL_CURRENT_BIT                 export
2       -->constant GL_POINT_BIT                        'GL_POINT_BIT                   export
4       -->constant GL_LINE_BIT                         'GL_LINE_BIT                    export
8       -->constant GL_POLYGON_BIT                      'GL_POLYGON_BIT                 export
16      -->constant GL_POLYGON_STIPPLE_BIT              'GL_POLYGON_STIPPLE_BIT         export
32      -->constant GL_PIXEL_MODE_BIT                   'GL_PIXEL_MODE_BIT              export
64      -->constant GL_LIGHTING_BIT                     'GL_LIGHTING_BIT                export
128     -->constant GL_FOG_BIT                          'GL_FOG_BIT                     export
256     -->constant GL_DEPTH_BUFFER_BIT                 'GL_DEPTH_BUFFER_BIT            export
512     -->constant GL_ACCUM_BUFFER_BIT                 'GL_ACCUM_BUFFER_BIT            export
1024    -->constant GL_STENCIL_BUFFER_BIT               'GL_STENCIL_BUFFER_BIT          export
2048    -->constant GL_VIEWPORT_BIT                     'GL_VIEWPORT_BIT                export
4096    -->constant GL_TRANSFORM_BIT                    'GL_TRANSFORM_BIT               export
8192    -->constant GL_ENABLE_BIT                       'GL_ENABLE_BIT                  export
16384   -->constant GL_COLOR_BUFFER_BIT                 'GL_COLOR_BUFFER_BIT            export
32768   -->constant GL_HINT_BIT                         'GL_HINT_BIT                    export
65536   -->constant GL_EVAL_BIT                         'GL_EVAL_BIT                    export
131072  -->constant GL_LIST_BIT                         'GL_LIST_BIT                    export
262144  -->constant GL_TEXTURE_BIT                      'GL_TEXTURE_BIT                 export
524288  -->constant GL_SCISSOR_BIT                      'GL_SCISSOR_BIT                 export
1048575 -->constant GL_ALL_ATTRIB_BITS                  'GL_ALL_ATTRIB_BITS             export

1     -->constant GL_CLIENT_PIXEL_STORE_BIT             'GL_CLIENT_PIXEL_STORE_BIT      export
2     -->constant GL_CLIENT_VERTEX_ARRAY_BIT            'GL_CLIENT_VERTEX_ARRAY_BIT     export
65535 -->constant GL_CLIENT_ALL_ATTRIB_BITS             'GL_CLIENT_ALL_ATTRIB_BITS      export

0 -->constant GL_NO_ERROR                               'GL_NO_ERROR                    export
        
1 -->constant GL_EXT_blend_color                        'GL_EXT_blend_color             export
1 -->constant GL_EXT_blend_logic_op                     'GL_EXT_blend_logic_op          export
1 -->constant GL_EXT_blend_minmax                       'GL_EXT_blend_minmax            export
1 -->constant GL_EXT_blend_subtract                     'GL_EXT_blend_subtract          export
1 -->constant GL_EXT_polygon_offset                     'GL_EXT_polygon_offset          export
1 -->constant GL_EXT_vertex_array                       'GL_EXT_vertex_array            export
1 -->constant GL_EXT_texture_object                     'GL_EXT_texture_object          export
1 -->constant GL_EXT_texture3D                          'GL_EXT_texture3D               export
1 -->constant GL_EXT_paletted_texture                   'GL_EXT_paletted_texture        export
1 -->constant GL_EXT_shared_texture_palette             'GL_EXT_shared_texture_palette  export
1 -->constant GL_EXT_point_parameters                   'GL_EXT_point_parameters        export
1 -->constant GL_EXT_rescale_normal                     'GL_EXT_rescale_normal          export
1 -->constant GL_EXT_abgr                               'GL_EXT_abgr                    export
1 -->constant GL_EXT_multitexture                       'GL_EXT_multitexture            export
1 -->constant GL_MESA_window_pos                        'GL_MESA_window_pos             export
1 -->constant GL_MESA_resize_buffers                    'GL_MESA_resize_buffers         export
1 -->constant GL_SGIS_multitexture                      'GL_SGIS_multitexture           export
1 -->constant GL_SGIS_texture_edge_clamp                'GL_SGIS_texture_edge_clamp     export


GL_TRUE  -->constant GLU_TRUE   	 'GLU_TRUE export
GL_FALSE -->constant GLU_FALSE  	 'GLU_FALSE export


100000 -->constant GLU_SMOOTH		'GLU_SMOOTH export
100001 -->constant GLU_FLAT		'GLU_FLAT export
100002 -->constant GLU_NONE		'GLU_NONE export
100010 -->constant GLU_POINT		'GLU_POINT export
100011 -->constant GLU_LINE		'GLU_LINE export
100012 -->constant GLU_FILL		'GLU_FILL export
100013 -->constant GLU_SILHOUETTE		'GLU_SILHOUETTE export
100020 -->constant GLU_OUTSIDE		'GLU_OUTSIDE export
100021 -->constant GLU_INSIDE		'GLU_INSIDE export
100100 -->constant GLU_BEGIN		'GLU_BEGIN export
100101 -->constant GLU_VERTEX		'GLU_VERTEX export
100102 -->constant GLU_END			'GLU_END export
100103 -->constant GLU_ERROR		'GLU_ERROR export
100104 -->constant GLU_EDGE_FLAG		'GLU_EDGE_FLAG export
100120 -->constant GLU_CW			'GLU_CW export
100121 -->constant GLU_CCW			'GLU_CCW export
100122 -->constant GLU_INTERIOR		'GLU_INTERIOR export
100123 -->constant GLU_EXTERIOR		'GLU_EXTERIOR export
100124 -->constant GLU_UNKNOWN		'GLU_UNKNOWN export
100151 -->constant GLU_TESS_ERROR1		'GLU_TESS_ERROR1 export
100152 -->constant GLU_TESS_ERROR2 	'GLU_TESS_ERROR2 export
100153 -->constant GLU_TESS_ERROR3 	'GLU_TESS_ERROR3 export
100154 -->constant GLU_TESS_ERROR4 	'GLU_TESS_ERROR4 export
100155 -->constant GLU_TESS_ERROR5 	'GLU_TESS_ERROR5 export
100156 -->constant GLU_TESS_ERROR6 	'GLU_TESS_ERROR6 export
100157 -->constant GLU_TESS_ERROR7 	'GLU_TESS_ERROR7 export
100158 -->constant GLU_TESS_ERROR8 	'GLU_TESS_ERROR8 export
100159 -->constant GLU_TESS_ERROR9 	'GLU_TESS_ERROR9 export
100200 -->constant GLU_AUTO_LOAD_MATRIX	 	'GLU_AUTO_LOAD_MATRIX export
100201 -->constant GLU_CULLING		 	'GLU_CULLING export
100202 -->constant GLU_PARAMETRIC_TOLERANCE 	'GLU_PARAMETRIC_TOLERANCE export
100203 -->constant GLU_SAMPLING_TOLERANCE	 	'GLU_SAMPLING_TOLERANCE export
100204 -->constant GLU_DISPLAY_MODE	 	'GLU_DISPLAY_MODE export
100205 -->constant GLU_SAMPLING_METHOD	 	'GLU_SAMPLING_METHOD export
100206 -->constant GLU_U_STEP		 	'GLU_U_STEP export
100207 -->constant GLU_V_STEP		 	'GLU_V_STEP export
100215 -->constant GLU_PATH_LENGTH		 	'GLU_PATH_LENGTH export
100216 -->constant GLU_PARAMETRIC_ERROR	 	'GLU_PARAMETRIC_ERROR export
100217 -->constant GLU_DOMAIN_DISTANCE	 	'GLU_DOMAIN_DISTANCE export
100210 -->constant GLU_MAP1_TRIM_2		 	'GLU_MAP1_TRIM_2 export
100211 -->constant GLU_MAP1_TRIM_3		 	'GLU_MAP1_TRIM_3 export
100240 -->constant GLU_OUTLINE_POLYGON	 	'GLU_OUTLINE_POLYGON export
100241 -->constant GLU_OUTLINE_PATCH	 	'GLU_OUTLINE_PATCH export
100251 -->constant GLU_NURBS_ERROR1  	'GLU_NURBS_ERROR1 export
100252 -->constant GLU_NURBS_ERROR2  	'GLU_NURBS_ERROR2 export
100253 -->constant GLU_NURBS_ERROR3  	'GLU_NURBS_ERROR3 export
100254 -->constant GLU_NURBS_ERROR4  	'GLU_NURBS_ERROR4 export
100255 -->constant GLU_NURBS_ERROR5  	'GLU_NURBS_ERROR5 export
100256 -->constant GLU_NURBS_ERROR6  	'GLU_NURBS_ERROR6 export
100257 -->constant GLU_NURBS_ERROR7  	'GLU_NURBS_ERROR7 export
100258 -->constant GLU_NURBS_ERROR8  	'GLU_NURBS_ERROR8 export
100259 -->constant GLU_NURBS_ERROR9  	'GLU_NURBS_ERROR9 export
100260 -->constant GLU_NURBS_ERROR10 	'GLU_NURBS_ERROR10 export
100261 -->constant GLU_NURBS_ERROR11 	'GLU_NURBS_ERROR11 export
100262 -->constant GLU_NURBS_ERROR12 	'GLU_NURBS_ERROR12 export
100263 -->constant GLU_NURBS_ERROR13 	'GLU_NURBS_ERROR13 export
100264 -->constant GLU_NURBS_ERROR14 	'GLU_NURBS_ERROR14 export
100265 -->constant GLU_NURBS_ERROR15 	'GLU_NURBS_ERROR15 export
100266 -->constant GLU_NURBS_ERROR16 	'GLU_NURBS_ERROR16 export
100267 -->constant GLU_NURBS_ERROR17 	'GLU_NURBS_ERROR17 export
100268 -->constant GLU_NURBS_ERROR18 	'GLU_NURBS_ERROR18 export
100269 -->constant GLU_NURBS_ERROR19 	'GLU_NURBS_ERROR19 export
100270 -->constant GLU_NURBS_ERROR20 	'GLU_NURBS_ERROR20 export
100271 -->constant GLU_NURBS_ERROR21 	'GLU_NURBS_ERROR21 export
100272 -->constant GLU_NURBS_ERROR22 	'GLU_NURBS_ERROR22 export
100273 -->constant GLU_NURBS_ERROR23 	'GLU_NURBS_ERROR23 export
100274 -->constant GLU_NURBS_ERROR24 	'GLU_NURBS_ERROR24 export
100275 -->constant GLU_NURBS_ERROR25 	'GLU_NURBS_ERROR25 export
100276 -->constant GLU_NURBS_ERROR26 	'GLU_NURBS_ERROR26 export
100277 -->constant GLU_NURBS_ERROR27 	'GLU_NURBS_ERROR27 export
100278 -->constant GLU_NURBS_ERROR28 	'GLU_NURBS_ERROR28 export
100279 -->constant GLU_NURBS_ERROR29 	'GLU_NURBS_ERROR29 export
100280 -->constant GLU_NURBS_ERROR30 	'GLU_NURBS_ERROR30 export
100281 -->constant GLU_NURBS_ERROR31 	'GLU_NURBS_ERROR31 export
100282 -->constant GLU_NURBS_ERROR32 	'GLU_NURBS_ERROR32 export
100283 -->constant GLU_NURBS_ERROR33 	'GLU_NURBS_ERROR33 export
100284 -->constant GLU_NURBS_ERROR34 	'GLU_NURBS_ERROR34 export
100285 -->constant GLU_NURBS_ERROR35 	'GLU_NURBS_ERROR35 export
100286 -->constant GLU_NURBS_ERROR36 	'GLU_NURBS_ERROR36 export
100287 -->constant GLU_NURBS_ERROR37 	'GLU_NURBS_ERROR37 export
100900 -->constant GLU_INVALID_ENUM  	'GLU_INVALID_ENUM export
100901 -->constant GLU_INVALID_VALUE 	'GLU_INVALID_VALUE export
100902 -->constant GLU_OUT_OF_MEMORY 	'GLU_OUT_OF_MEMORY export
100903 -->constant GLU_INCOMPATIBLE_GL_VERSION	'GLU_INCOMPATIBLE_GL_VERSION export
100800 -->constant GLU_VERSION 	'GLU_VERSION export
100801 -->constant GLU_EXTENSIONS 	'GLU_EXTENSIONS export


( ===================================================================== )
( - functions                                                           )

( ===================================================================== )
( - glutInit -- dummy to humor people who insist on having it           )

:   glutInit { $ $ -> }
    pop
    pop
;
'glutInit export

( ===================================================================== )
( - glutDisplayFunc                                                     )

:   glutDisplayFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutDisplayFunc
;
'glutDisplayFunc export

( ===================================================================== )
( - glutOverlayDisplayFunc                                              )

:   glutOverlayDisplayFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutOverlayDisplayFunc
;
'glutOverlayDisplayFunc export

( ===================================================================== )
( - glutReshapeFunc                                                     )

:   glutReshapeFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutReshapeFunc
;
'glutReshapeFunc export

( ===================================================================== )
( - glutKeyboardFunc                                                    )

:   glutKeyboardFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutKeyboardFunc
;
'glutKeyboardFunc export

( ===================================================================== )
( - glutKeyboardUpFunc                                                  )

:   glutKeyboardUpFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutKeyboardUpFunc
;
'glutKeyboardUpFunc export

( ===================================================================== )
( - glutMouseFunc                                                       )

:   glutMouseFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutMouseFunc
;
'glutMouseFunc export

( ===================================================================== )
( - glutMotionFunc                                                      )

:   glutMotionFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutMotionFunc
;
'glutMotionFunc export

( ===================================================================== )
( - glutPassiveMotionFunc                                               )

:   glutPassiveMotionFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutPassiveMotionFunc
;
'glutPassiveMotionFunc export

( ===================================================================== )
( - glutVisibilityFunc                                                  )

:   glutVisibilityFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutVisibilityFunc
;
'glutVisibilityFunc export

( ===================================================================== )
( - glutEntryFunc                                                       )

:   glutEntryFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutEntryFunc
;
'glutEntryFunc export

( ===================================================================== )
( - glutSpecialFunc                                                     )

:   glutSpecialFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutSpecialFunc
;
'glutSpecialFunc export

( ===================================================================== )
( - glutSpecialUpFunc                                                   )

:   glutSpecialUpFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutSpecialUpFunc
;
'glutSpecialUpFunc export

( ===================================================================== )
( - glutSpaceballMotionFunc                                             )

:   glutSpaceballMotionFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutSpaceballMotionFunc
;
'glutSpaceballMotionFunc export

( ===================================================================== )
( - glutSpaceballRotateFunc                                             )

:   glutSpaceballRotateFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutSpaceballRotateFunc
;
'glutSpaceballRotateFunc export

( ===================================================================== )
( - glutSpaceballButtonFunc                                             )

:   glutSpaceballButtonFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutSpaceballButtonFunc
;
'glutSpaceballButtonFunc export

( ===================================================================== )
( - glutButtonBoxFunc                                                   )

:   glutButtonBoxFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutButtonBoxFunc
;
'glutButtonBoxFunc export

( ===================================================================== )
( - glutDialsFunc                                                       )

:   glutDialsFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutDialsFunc
;
'glutDialsFunc export

( ===================================================================== )
( - glutTabletMotionFunc                                                )

:   glutTabletMotionFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutTabletMotionFunc
;
'glutTabletMotionFunc export

( ===================================================================== )
( - glutTabletButtonFunc                                                )

:   glutTabletButtonFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutTabletButtonFunc
;
'glutTabletButtonFunc export

( ===================================================================== )
( - glutWindowStatusFunc                                                )

:   glutWindowStatusFunc { $ -> }
    -> fn

    glutGetWindow -> w
    fn --> w.glutWindowStatusFunc
;
'glutWindowStatusFunc export

( ===================================================================== )
( - glutMenusStatusFunc                                                 )

:   glutMenuStatusFunc { $ -> }
    -> fn

    fn --> .muq.glutMenuStatusFunc
;
'glutMenuStatusFunc export

( ===================================================================== )
( - glutIdleFunc                                                        )

:   glutIdleFunc { $ -> }
    -> fn

    fn --> .muq.glutIdleFunc
;
'glutIdleFunc export

( ===================================================================== )
( - glutTimerFunc                                                       )

:   glutTimerFunc { $ -> }
    -> fn

    fn --> .muq.glutTimerFunc
;
'glutTimerFunc export

( ===================================================================== )
( - glutReportErrors                                                    )

:   glutReportErrors { -> }
    do{
	glGetError -> error
        error GL_NO_ERROR = until
        [ "GL error: %s\n" error gluErrorString | ]print ,
    }
;

( ===================================================================== )
( - gluqExitableLoop                                                    )

:   gluqExitableLoop { $ $ -> }
    -> loopsleft
    -> exitchar

    glutGetWindow not if
	"glutExitableLoop called before any windows created" simpleError
    fi


    ( Default value here gives a 1-sec lag )
    ( in response to key/mouse input:      )
    1000 --> .muq.maxMicrosecondsToSleepInIdleSelect

    ( Could wrap an error trap around the loop, )
    ( but being able to ^C out is handy.        )
    do{
	-- loopsleft
	loopsleft 0 = if return fi

        glFlush

	gluqEvent
	|shift -> op

	op not if
	    ]pop
	    10 sleepJob
	    loopNext
        fi

	|shift -> wdw	( Window recieving the event )
	wdw not if
	    ]pop
	    10 sleepJob
	    loopNext
	fi
	wdw glutSetWindow

	op case{

	on: "Display"
	    ]pop
	    wdw.glutDisplayFunc -> w
	    w callable? if w call{ -> } fi

	on: "Passive"
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutPassiveMotionFunc -> w
	    w callable? if x y w call{ $ $ -> } fi
	    
	on: "Motion"
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutMotionFunc -> w
	    w callable? if x y w call{ $ $ -> } fi
	    
	on: "Key"
	    |shift -> key
	    |shift -> x
	    |shift -> y
	    ]pop
	    exitchar key = if return fi
	    wdw.glutKeyboardFunc -> w
	    w callable? if key x y w call{ $ $ $ -> } fi
	    
	on: "KeyUp"
	    |shift -> key
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutKeyboardUpFunc -> w
	    w callable? if key x y w call{ $ $ $ -> } fi
	    
	on: "Reshape"
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutReshapeFunc -> w
	    w callable? if x y w call{ $ $ -> } fi

	on: "Mouse"
	    |shift -> state
	    |shift -> button
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutMouseFunc -> w
	    w callable? if state button x y w call{ $ $ $ $ -> } fi

	on: "FnKey"
	    |shift -> key
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutSpecialFunc -> w
	    w callable? if key x y w call{ $ $ $ -> } fi
	    
	on: "FnKeyUp"
	    |shift -> key
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutSpecialUpFunc -> w
	    w callable? if key x y w call{ $ $ $ -> } fi
	    
	on: "Entry"
	    |shift -> state
	    ]pop
	    wdw.glutEntryFunc -> w
	    w callable? if state w call{ $ $ $ -> } fi
	    
	on: "Visible"
	    |shift -> state
	    ]pop
	    wdw.glutVisibilityFunc -> w
	    w callable? if state w call{ $ $ $ -> } fi
	    
	on: "Status"
	    |shift -> state
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutStatusFunc -> w
	    w callable? if state x y w call{ $ $ $ -> } fi
	    
	on: "Buttons"
	    |shift -> button
	    |shift -> state
	    ]pop
	    wdw.glutButtonBoxFunc -> w
	    w callable? if button state w call{ $ $ $ -> } fi
	    
	on: "Dials"
	    |shift -> dial
	    |shift -> x
	    ]pop
	    wdw.glutDialsFunc -> w
	    w callable? if dial x w call{ $ $ $ -> } fi
	    
	on: "PadXY"
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutTabletMotionFunc -> w
	    w callable? if x y w call{ $ $ $ -> } fi
	    
	on: "PadKey"
	    |shift -> button
	    |shift -> state
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutTabletButtonFunc -> w
	    w callable? if x y w call{ $ $ $ -> } fi
	    
	on: "BallXYZ"
	    |shift -> x
	    |shift -> y
	    |shift -> z
	    ]pop
	    wdw.glutSpaceballMotionFunc -> w
	    w callable? if x y z w call{ $ $ $ -> } fi
	    
	on: "BallRot"
	    |shift -> x
	    |shift -> y
	    |shift -> z
	    ]pop
	    wdw.glutSpaceballRotateFunc -> w
	    w callable? if x y z w call{ $ $ $ -> } fi
	    
	on: "BallKey"
	    |shift -> button
	    |shift -> state
	    ]pop
	    wdw.glutSpaceballButtonFunc -> w
	    w callable? if button state w call{ $ $ $ -> } fi
	    
	else:
	    ]pop
	    10 sleepJob
	    loopNext
	}	
    }
;
'gluqExitableLoop export
( buggo, above and below loops should really be )
( merged into one.  But when I tried this, the  )
( code calling it was flagged as an attempt to  )
( use a void result in an expression.  Need to  )
( to a little more hacking on the MUC compiler. )

( ===================================================================== )
( - glutMainLoop                                                        )

:   glutMainLoop { -> @ }

    glutGetWindow not if
	"glutMainLoop called before any windows created" simpleError
    fi


    ( Default value here gives a 1-sec lag )
    ( in response to key/mouse input:      )
    1000 --> .muq.maxMicrosecondsToSleepInIdleSelect

    ( Could wrap an error trap around the loop, )
    ( but being able to ^C out is handy.        )
    do{

        glFlush

	gluqEvent
	|shift -> op

	op not if
	    ]pop
	    10 sleepJob
	    loopNext
        fi

	|shift -> wdw	( Window recieving the event )
	wdw not if
	    ]pop
	    10 sleepJob
	    loopNext
	fi
	wdw glutSetWindow

	op case{

	on: "Display"
	    ]pop
	    wdw.glutDisplayFunc -> w
	    w callable? if w call{ -> } fi

	on: "Passive"
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutPassiveMotionFunc -> w
	    w callable? if x y w call{ $ $ -> } fi
	    
	on: "Motion"
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutMotionFunc -> w
	    w callable? if x y w call{ $ $ -> } fi
	    
	on: "Key"
	    |shift -> key
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutKeyboardFunc -> w
	    w callable? if key x y w call{ $ $ $ -> } fi
	    
	on: "KeyUp"
	    |shift -> key
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutKeyboardUpFunc -> w
	    w callable? if key x y w call{ $ $ $ -> } fi
	    
	on: "Reshape"
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutReshapeFunc -> w
	    w callable? if x y w call{ $ $ -> } fi

	on: "Mouse"
	    |shift -> state
	    |shift -> button
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutMouseFunc -> w
	    w callable? if state button x y w call{ $ $ $ $ -> } fi

	on: "FnKey"
	    |shift -> key
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutSpecialFunc -> w
	    w callable? if key x y w call{ $ $ $ -> } fi
	    
	on: "FnKeyUp"
	    |shift -> key
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutSpecialUpFunc -> w
	    w callable? if key x y w call{ $ $ $ -> } fi
	    
	on: "Entry"
	    |shift -> state
	    ]pop
	    wdw.glutEntryFunc -> w
	    w callable? if state w call{ $ $ $ -> } fi
	    
	on: "Visible"
	    |shift -> state
	    ]pop
	    wdw.glutVisibilityFunc -> w
	    w callable? if state w call{ $ $ $ -> } fi
	    
	on: "Status"
	    |shift -> state
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutStatusFunc -> w
	    w callable? if state x y w call{ $ $ $ -> } fi
	    
	on: "Buttons"
	    |shift -> button
	    |shift -> state
	    ]pop
	    wdw.glutButtonBoxFunc -> w
	    w callable? if button state w call{ $ $ $ -> } fi
	    
	on: "Dials"
	    |shift -> dial
	    |shift -> x
	    ]pop
	    wdw.glutDialsFunc -> w
	    w callable? if dial x w call{ $ $ $ -> } fi
	    
	on: "PadXY"
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutTabletMotionFunc -> w
	    w callable? if x y w call{ $ $ $ -> } fi
	    
	on: "PadKey"
	    |shift -> button
	    |shift -> state
	    |shift -> x
	    |shift -> y
	    ]pop
	    wdw.glutTabletButtonFunc -> w
	    w callable? if x y w call{ $ $ $ -> } fi
	    
	on: "BallXYZ"
	    |shift -> x
	    |shift -> y
	    |shift -> z
	    ]pop
	    wdw.glutSpaceballMotionFunc -> w
	    w callable? if x y z w call{ $ $ $ -> } fi
	    
	on: "BallRot"
	    |shift -> x
	    |shift -> y
	    |shift -> z
	    ]pop
	    wdw.glutSpaceballRotateFunc -> w
	    w callable? if x y z w call{ $ $ $ -> } fi
	    
	on: "BallKey"
	    |shift -> button
	    |shift -> state
	    ]pop
	    wdw.glutSpaceballButtonFunc -> w
	    w callable? if button state w call{ $ $ $ -> } fi
	    
	else:
	    ]pop
	    10 sleepJob
	    loopNext
	}	
    }
;
'glutMainLoop export

( ===================================================================== )
( - File variables                                                      )


( Local variables:                                                      )
( mode: outline-minor                                                   )
( outline-regexp: "( -+"                                                )
( End:                                                                  )

@end example
