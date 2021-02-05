/*--   obj_std_props.h -- Properties to be included on all objects.	*/
/* This file is formatted for emacs' outline-minor-mode.		*/



    /* Values to go in all system_properties[] tables: */

#ifdef OLD
    {0,"owner"  , obj_Owner  , obj_Set_Owner	},
#else
    {0,"owner"  , obj_Owner  , obj_Set_Never	},
#endif
#ifdef OLD
    {0,"parents", obj_Parents, obj_Set_Parents	},
    {0,"changed", obj_Changed, obj_Set_Changed	},
    {0,"changor", obj_Changor, obj_Set_Changor	},
    {0,"created", obj_Created, obj_Set_Created	},
    {0,"creator", obj_Creator, obj_Set_Creator	},
#endif
    {0,"myclass", obj_Myclass, obj_Set_Myclass	},
    {0,"name"   , obj_Objname, obj_Set_Objname	},
    {0,"isA"    , obj_Is_A,    obj_Set_Is_A	},
    {0,"dbname" , obj_Dbname,  obj_Set_Never	},

    /* Include patches for optional modules.  */
    /* This is a trifle tricky because we may */
    /* be doing a patch within a patch, which */
    /* can result in an #include loop:        */
    #ifndef  MODULES_MODULES_C

    #define  MODULES_OBJ_STD_PROPS_H
    #include "Modules.h"
    #undef   MODULES_OBJ_STD_PROPS_H

    #else

    #undef   MODULES_MODULES_C
    #define  MODULES_OBJ_STD_PROPS_H
    #include "Modules.h"
    #undef   MODULES_OBJ_STD_PROPS_H
    #define  MODULES_MODULES_C

    #endif


/************************************************************************/
/*-    File variables */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/


