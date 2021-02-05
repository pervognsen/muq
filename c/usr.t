@example  @c
/*-To do: */

/* Install a privilege bit to enable use of */
/* unmaskable kill signal?  Since these */
/* defeat after{}alwaysDo{}, malicious users can */
/* attempt to smash up the system a bit by invoking */
/* random system utilities and killing them off in */
/* midprocessing.  Possibly unmaskable kill issued */
/* by nonroot should complete processing of all */
/* code not owned by the issuer before actually doing */
/* the kill?  Or...? */

/* Construct a 256-bit privilege block in each user, */
/* probably 16 bits per word to simplify indexing,   */
/* and an ": priv? { i -- b } ;" prim that checks    */
/* any of the 256 bits.  Use R for Root, U for user, */
/* leave the rest free for			     */
/* assignment.  256 means any European char can be   */
/* used as a flag. Setting flags is a root-priv prim.*/
/* Privs of acting user live in global job context,  */
/* for fast checking, copied back and forth by       */
/* structure assignment. Then collapse current four  */
/* classes into one user class.                      */
/* Hmm.  "WG" ? would be a good prim format, actually*/
/* True iff bits corresponding to all chars are set. */
/* Checking to see whether a given user has a given  */
/* bit set should probably be a privileged operation;*/
/* checking to see whether the job is currently      */
/* running with a given bit set should be a public   */
/* operation.  Likely we should have a generic op    */
/* "aGW" as{ ... } that sets given flags on process  */
/* for given scope.                                  */


/*--   usr.c -- USeR objects for Muq.					*/
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
/* Created:      93Feb22						*/
/* Modified:								*/
/* Language:     C							*/
/* Package:      N/A							*/
/* Status:       							*/
/* 									*/
/* Copyright (c) 1993-1995, by Jeff Prothero.				*/
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
/*-    Overview								*/
/************************************************************************/

/************************************************************************/
/*

 ************************************************************************/




/************************************************************************/
/*-    #includes							*/
/************************************************************************/

#include "All.h"



/************************************************************************/
/*-    #defines								*/
/************************************************************************/

/* Concise access to user record: */
#undef  U
#define U(o) USR_P(o)



/************************************************************************/
/*-    Types								*/
/************************************************************************/



/************************************************************************/
/*-    Statics								*/
/************************************************************************/

#if MUQ_DEBUG
static Vm_Int   invariants(FILE*,char*,Vm_Obj);
#endif

static void     for_new(    Vm_Obj, Vm_Unt );
static Vm_Unt   sizeof_usr( Vm_Unt );

static Vm_Obj	usr_do_break(            Vm_Obj        );
static Vm_Obj	usr_byte_quota(          Vm_Obj        );
static Vm_Obj	usr_bytes_owned(         Vm_Obj        );
static Vm_Obj	usr_break_disable(       Vm_Obj        );
static Vm_Obj	usr_break_enable(        Vm_Obj        );
static Vm_Obj	usr_break_on_signal(     Vm_Obj        );
static Vm_Obj	usr_dbref_convert_errors(Vm_Obj        );
static Vm_Obj	usr_debugger(            Vm_Obj        );
static Vm_Obj	usr_do_not_disturb(      Vm_Obj        );
static Vm_Obj	usr_doing(               Vm_Obj        );
static Vm_Obj	usr_do_signal(           Vm_Obj        );
static Vm_Obj	usr_email(               Vm_Obj	       );
static Vm_Obj	usr_homepage(            Vm_Obj	       );
static Vm_Obj	usr_pgp_keyprint(        Vm_Obj	       );
static Vm_Obj	usr_config_fns(          Vm_Obj        );
static Vm_Obj	usr_login_hints(         Vm_Obj        );
static Vm_Obj	usr_ps_queue(            Vm_Obj        );
static Vm_Obj	usr_pause_queue(         Vm_Obj        );
static Vm_Obj	usr_run_queue_0(         Vm_Obj        );
static Vm_Obj	usr_run_queue_1(         Vm_Obj        );
static Vm_Obj	usr_run_queue_2(         Vm_Obj        );
static Vm_Obj	usr_halt_queue(          Vm_Obj        );
static Vm_Obj	usr_object_quota(        Vm_Obj        );
static Vm_Obj	usr_objects_owned(       Vm_Obj        );
static Vm_Obj	usr_group(               Vm_Obj        );
static Vm_Obj	usr_lib(                 Vm_Obj        );
static Vm_Obj	usr_package(             Vm_Obj        );
static Vm_Obj	usr_shell(               Vm_Obj        );
static Vm_Obj	usr_telnet_daemon(       Vm_Obj        );
static Vm_Obj	usr_text_editor(         Vm_Obj        );
static Vm_Obj	usr_time_slice(          Vm_Obj        );
static Vm_Obj	usr_set_break_disable(   Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_break_enable(    Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_break_on_signal( Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_do_break(        Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_byte_quota(      Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_bytes_owned(     Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_debugger(        Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_do_not_disturb(  Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_doing(           Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_do_signal(       Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_email(           Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_homepage(        Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_pgp_keyprint(    Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_config_fns(      Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_login_hints(     Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_object_quota(    Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_objects_owned(   Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_group(           Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_lib(             Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_package(         Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_shell(           Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_telnet_daemon(   Vm_Obj, Vm_Obj );
static Vm_Obj	usr_set_text_editor(     Vm_Obj, Vm_Obj );

static Vm_Obj	usr_encrypted_passphrase(  Vm_Obj       );
static Vm_Obj	usr_set_encrypted_passphrase(Vm_Obj,Vm_Obj);

static Vm_Obj	usr_www(   		 Vm_Obj       	);
static Vm_Obj	usr_set_www(		 Vm_Obj,Vm_Obj	);

static Vm_Obj	usr_rank(   		 Vm_Obj       	);
static Vm_Obj	usr_set_rank(		 Vm_Obj,Vm_Obj	);

static Vm_Obj	usr_gagged(   		 Vm_Obj       	);
static Vm_Obj	usr_set_gagged(		 Vm_Obj,Vm_Obj	);

static Vm_Obj	usr_priv_bits(   		 Vm_Obj       	);
static Vm_Obj	usr_set_priv_bits(		 Vm_Obj,Vm_Obj	);

static Vm_Obj	usr_set_never( Vm_Obj, Vm_Obj );

static Vm_Obj	usr_unrestricted_opengl( Vm_Obj );
static Vm_Obj	usr_set_unrestricted_opengl( Vm_Obj, Vm_Obj );

static Vm_Obj	usr_avatar_opengl( Vm_Obj );
static Vm_Obj	usr_set_avatar_opengl( Vm_Obj, Vm_Obj );

static Vm_Obj	usr_nick_name(           Vm_Obj         );
static Vm_Obj	usr_long_name(           Vm_Obj         );
static Vm_Obj	usr_true_name(           Vm_Obj         );
static Vm_Obj	usr_hash_name(           Vm_Obj         );
static Vm_Obj	usr_shared_secrets(      Vm_Obj         );
static Vm_Obj	usr_last_long_name(      Vm_Obj         );
static Vm_Obj	usr_last_true_name(      Vm_Obj         );
static Vm_Obj	usr_last_hash_name(      Vm_Obj         );
static Vm_Obj	usr_last_shared_secrets( Vm_Obj         );
static Vm_Obj	usr_original_nick_name(  Vm_Obj         );
static Vm_Obj	usr_date_of_last_name_change( Vm_Obj    );
static Vm_Obj	usr_ip0(                 Vm_Obj         );
static Vm_Obj	usr_ip1(                 Vm_Obj         );
static Vm_Obj	usr_ip2(                 Vm_Obj         );
static Vm_Obj	usr_ip3(                 Vm_Obj         );
static Vm_Obj	usr_port(                Vm_Obj         );
static Vm_Obj	usr_io_stream(           Vm_Obj         );
static Vm_Obj	usr_user_server_0(   Vm_Obj         );
static Vm_Obj	usr_user_server_1(   Vm_Obj         );
static Vm_Obj	usr_user_server_2(   Vm_Obj         );
static Vm_Obj	usr_user_server_3(   Vm_Obj         );
static Vm_Obj	usr_user_server_4(   Vm_Obj         );
static Vm_Obj	usr_user_server_1_needs_updating( Vm_Obj   );
static Vm_Obj	usr_user_server_2_needs_updating( Vm_Obj   );
static Vm_Obj	usr_user_server_3_needs_updating( Vm_Obj   );
static Vm_Obj	usr_user_server_4_needs_updating( Vm_Obj   );
static Vm_Obj	usr_has_unknown_user_server(    Vm_Obj         );
static Vm_Obj	usr_user_version(    Vm_Obj         );
static Vm_Obj	usr_date_at_which_we_last_queried_user_servers(    Vm_Obj         );

static Vm_Obj	usr_packet_preprocessor(    Vm_Obj         );
static Vm_Obj	usr_packet_postprocessor(   Vm_Obj         );
static Vm_Obj	usr_first_used_by_muqnet(   Vm_Obj         );
static Vm_Obj	usr_last_used_by_muqnet(    Vm_Obj         );
static Vm_Obj	usr_times_used_by_muqnet(   Vm_Obj         );

static Vm_Obj	usr_set_packet_preprocessor(  Vm_Obj,Vm_Obj );
static Vm_Obj	usr_set_packet_postprocessor( Vm_Obj,Vm_Obj );


static Vm_Obj	usr_set_nick_name(           Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_long_name(           Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_true_name(           Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_hash_name(           Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_shared_secrets(      Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_last_long_name(      Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_last_true_name(      Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_last_hash_name(      Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_last_shared_secrets( Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_original_nick_name(  Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_ip0(                 Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_ip1(                 Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_ip2(                 Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_ip3(                 Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_port(                Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_io_stream(           Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_user_server_0(   Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_user_server_1(   Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_user_server_2(   Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_user_server_3(   Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_user_server_4(   Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_user_server_1_needs_updating(  Vm_Obj, Vm_Obj  );
static Vm_Obj	usr_set_user_server_2_needs_updating(  Vm_Obj, Vm_Obj  );
static Vm_Obj	usr_set_user_server_3_needs_updating(  Vm_Obj, Vm_Obj  );
static Vm_Obj	usr_set_user_server_4_needs_updating(  Vm_Obj, Vm_Obj  );
static Vm_Obj	usr_set_user_version(    Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_has_unknown_user_server(    Vm_Obj, Vm_Obj         );
static Vm_Obj	usr_set_date_at_which_we_last_queried_user_servers(    Vm_Obj, Vm_Obj         );



/************************************************************************/
/*-    Globals								*/
/************************************************************************/

/* Description of standard-header system properties: */
static Obj_A_Special_Property usr_system_properties[] = {

    /* Include properties required on all objects: */
    #include "obj-std-props.h"

    /* Add properties special to this class: */
    {0,"byte-quota"	, usr_byte_quota     , usr_set_byte_quota	},
    {0,"bytes-owned"	, usr_bytes_owned    , usr_set_bytes_owned	},
    {0,"breakDisable"  , usr_break_disable  , usr_set_break_disable	},
    {0,"breakEnable"   , usr_break_enable   , usr_set_break_enable	},
    {0,"breakOnSignal", usr_break_on_signal, usr_set_break_on_signal	},
    {0,"dbrefConvertErrors", usr_dbref_convert_errors, usr_set_never	},
    {0,"debugger"       , usr_debugger       , usr_set_debugger		},
    {0,"defaultPackage", usr_package        , usr_set_package		},
    {0,"doBreak"       , usr_do_break       , usr_set_do_break		},
    {0,"doNotDisturb"  , usr_do_not_disturb , usr_set_do_not_disturb	},
    {0,"doSignal"      , usr_do_signal      , usr_set_do_signal		},
    {0,"doing"         , usr_doing          , usr_set_doing		},
    {0,"email"         , usr_email          , usr_set_email		},
    {0,"group"  	, usr_group	     , usr_set_group		},
    {0,"haltQueue"     , usr_halt_queue     , usr_set_never		},
    {0,"homepage"      , usr_homepage       , usr_set_homepage		},
    {0,"lib"		, usr_lib	     , usr_set_lib		},
    {0,"loginHints"	, usr_login_hints    , usr_set_login_hints	},
    {0,"configFns"	, usr_config_fns     , usr_set_config_fns	},
    {0,"objectQuota"	, usr_object_quota   , usr_set_object_quota	},
    {0,"objectsOwned"	, usr_objects_owned  , usr_set_objects_owned	},
    {0,"pauseQueue"    , usr_pause_queue    , usr_set_never		},
    {0,"pgpKeyprint"   , usr_pgp_keyprint   , usr_set_pgp_keyprint	},
    {0,"psQueue"       , usr_ps_queue       , usr_set_never		},
    {0,"runQueue0"    , usr_run_queue_0    , usr_set_never		},
    {0,"runQueue1"    , usr_run_queue_1    , usr_set_never		},
    {0,"runQueue2"    , usr_run_queue_2    , usr_set_never		},
    {0,"shell"		, usr_shell          , usr_set_shell		},
    {0,"telnetDaemon"	, usr_telnet_daemon  , usr_set_telnet_daemon	},
    {0,"textEditor"	, usr_text_editor    , usr_set_text_editor	},
    {0,"timeSlice"	, usr_time_slice     , usr_set_never		},
    {0,"unrestrictedOpenGL"	, usr_unrestricted_opengl   , usr_set_unrestricted_opengl },
    {0,"avatarOpenGL"	, usr_avatar_opengl   , usr_set_avatar_opengl },
    {0,"rank"		, usr_rank	     , usr_set_rank },
    {0,"gagged"		, usr_gagged	     , usr_set_gagged },
    {0,"privBits"	, usr_priv_bits	     , usr_set_priv_bits },
    {0,"nickName",	usr_nick_name,	usr_set_nick_name },
    {0,"longName",	usr_long_name,	usr_set_long_name },
    {0,"trueName",	usr_true_name,	usr_set_true_name },
    {0,"hashName",	usr_hash_name,	usr_set_hash_name },
    {0,"sharedSecrets",	usr_shared_secrets,	usr_set_shared_secrets },
    {0,"lastLongName",	usr_last_long_name,	usr_set_last_long_name },
    {0,"lastTrueName",	usr_last_true_name,	usr_set_last_true_name },
    {0,"lastHashName",	usr_last_hash_name,	usr_set_last_hash_name },
    {0,"lastSharedSecrets",	usr_last_shared_secrets,	usr_set_last_shared_secrets },
    {0,"originalNickName",	usr_original_nick_name,	usr_set_original_nick_name },
    {0,"dateOfLastNameChange",	usr_date_of_last_name_change,	usr_set_never },
    {0,"ioStream",	usr_io_stream,	usr_set_io_stream },
    {0,"ip0",	usr_ip0,	usr_set_ip0 },
    {0,"ip1",	usr_ip1,	usr_set_ip1 },
    {0,"ip2",	usr_ip2,	usr_set_ip2 },
    {0,"ip3",	usr_ip3,	usr_set_ip3 },
    {0,"port",	usr_port,	usr_set_port },
    {0,"hasUnknownUserServer",	usr_has_unknown_user_server,	usr_set_has_unknown_user_server },
    {0,"userVersion",	usr_user_version,	usr_set_user_version },
    {0,"userServer0",	usr_user_server_0,	usr_set_user_server_0 },
    {0,"userServer1",	usr_user_server_1,	usr_set_user_server_1 },
    {0,"userServer2",	usr_user_server_2,	usr_set_user_server_2 },
    {0,"userServer3",	usr_user_server_3,	usr_set_user_server_3 },
    {0,"userServer4",	usr_user_server_4,	usr_set_user_server_4 },
    {0,"userServer1NeedsUpdating",	usr_user_server_1_needs_updating,	usr_set_user_server_1_needs_updating },
    {0,"userServer2NeedsUpdating",	usr_user_server_2_needs_updating,	usr_set_user_server_2_needs_updating },
    {0,"userServer3NeedsUpdating",	usr_user_server_3_needs_updating,	usr_set_user_server_3_needs_updating },
    {0,"userServer4NeedsUpdating",	usr_user_server_4_needs_updating,	usr_set_user_server_4_needs_updating },
    {0,"dateAtWhichWeLastQueriedUserServers",	usr_date_at_which_we_last_queried_user_servers,	usr_set_date_at_which_we_last_queried_user_servers },
    {0,"packetPreprocessor",	usr_packet_preprocessor,	usr_set_packet_preprocessor },
    {0,"packetPostprocessor",	usr_packet_postprocessor,	usr_set_packet_postprocessor },
    {0,"firstUsedByMuqnet",	usr_first_used_by_muqnet,	usr_set_never },
    {0,"lastUsedByMuqnet",	usr_last_used_by_muqnet,	usr_set_never },
    {0,"timesUsedByMuqnet",	usr_times_used_by_muqnet,	usr_set_never },

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

/* Description of standard-header public properties: */
static Obj_A_Special_Property usr_public_properties[] = {

    {0,"www"		, usr_www	     , usr_set_www },

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

/* Description of standard-header admins properties: */
static Obj_A_Special_Property usr_admins_properties[] = {

    {0,"encryptedPassphrase"	, usr_encrypted_passphrase , usr_set_encrypted_passphrase },

    /* End-of-array sentinel: */
    {0,NULL,NULL,NULL}
};

Obj_A_Hardcoded_Class usr_Hardcoded_Rot_Class = {
    OBJ_FROM_BYT3('r','o','t'),
    "Root",
    sizeof_usr,
    for_new,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { usr_system_properties, usr_public_properties, NULL, usr_admins_properties /*, NULL*/ },
    obj_Import,
    obj_Export,
    OBJ_0
};
Obj_A_Hardcoded_Class usr_Hardcoded_Usr_Class = {
    OBJ_FROM_BYT3('u','s','r'),
    "User",
    sizeof_usr,
    for_new,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { usr_system_properties, usr_public_properties, NULL, usr_admins_properties /*, NULL*/ },
    obj_Import,
    obj_Export,
    OBJ_0
};
Obj_A_Hardcoded_Class usr_Hardcoded_Gst_Class = {
    OBJ_FROM_BYT3('g','s','t'),
    "Guest",
    sizeof_usr,
    for_new,
    obj_X_Del,
    obj_X_Get,
    obj_X_Get_Asciz,
    obj_X_Set,
    obj_X_Next,
    obj_X_Key,
    obj_Hash_Immediate,
    obj_Byteswap_64bit_Obj,
    obj_Get_Mos_Key,
    { usr_system_properties, usr_public_properties, NULL, usr_admins_properties /*, NULL*/ },
    obj_Import,
    obj_Export,
    OBJ_0
};

static void usr_doTypes(void){}
Obj_A_Module_Summary usr_Module_Summary = {
   "usr",
    usr_doTypes,
    usr_Startup,
    usr_Linkup,
    usr_Shutdown,
};




/************************************************************************/
/*-    --- Public fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    usr_Startup -- start-of-world stuff.				*/
/************************************************************************/

void
usr_Startup(
    void
) {

    static int done_startup   = FALSE;
    if        (done_startup)   return;
    done_startup	       = TRUE;

    obj_Startup();
}



/************************************************************************/
/*-    usr_Linkup -- start-of-world stuff.				*/
/************************************************************************/

void
usr_Linkup(
    void
) {

    static int done_linkup   = FALSE;
    if        (done_linkup)   return;
    done_linkup		      = TRUE;

    obj_Linkup();
}



/************************************************************************/
/*-    usr_Shutdown -- end-of-world stuff.				*/
/************************************************************************/

void
usr_Shutdown(
    void
) {

    static int done_shutdown   = FALSE;
    if        (done_shutdown)   return;
    done_shutdown	        = TRUE;

    obj_Shutdown();
}



/************************************************************************/
/*-    usr_Invariants -- Sanity check on usr.				*/
/************************************************************************/

/* We return FALSE unless we find any problems.	*/
/* We log problem reports to 'errlog'.		*/

int
usr_Invariants (
    FILE* errlog,
    char* title,
    Vm_Obj usr
) {
    int errs = 0;
#if MUQ_DEBUG
    errs    += invariants( errlog, title, usr );
#endif
    return errs;
}


#ifdef OLD

/************************************************************************/
/*-    usr_Import -- Read  object from textfile.			*/
/************************************************************************/

Vm_Obj
usr_Import(
    FILE* fd
) {
    MUQ_FATAL ("usr_Import unimplemented");
    return OBJ_NIL;
}



/************************************************************************/
/*-    usr_Export -- Write object into textfile.			*/
/************************************************************************/

void usr_Export(
    FILE* fd,
    Vm_Obj o
) {
    MUQ_FATAL ("usr_Export unimplemented");
}


#endif


/************************************************************************/
/*-    --- Core static fns ---						*/
/************************************************************************/


/************************************************************************/
/*-    for_new -- Initialize new usr object.				*/
/************************************************************************/

static void
for_new(
    Vm_Obj o,
    Vm_Unt size
) {
    Vm_Obj run_q[ JOB_PRIORITY_LEVELS ];
    Vm_Obj ps_q;
    Vm_Obj pause_q;
    Vm_Obj halt_q;
    Vm_Obj shared_secrets;
    Vm_Unt dbfile = VM_DBFILE(o);
    run_q[0] = obj_Alloc_In_Dbfile( OBJ_CLASS_A_JOQ, 0, dbfile );
    run_q[1] = obj_Alloc_In_Dbfile( OBJ_CLASS_A_JOQ, 0, dbfile );
    run_q[2] = obj_Alloc_In_Dbfile( OBJ_CLASS_A_JOQ, 0, dbfile );
    ps_q     = obj_Alloc_In_Dbfile( OBJ_CLASS_A_JOQ, 0, dbfile );
    pause_q  = obj_Alloc_In_Dbfile( OBJ_CLASS_A_JOQ, 0, dbfile );
    halt_q   = obj_Alloc_In_Dbfile( OBJ_CLASS_A_JOQ, 0, dbfile );
    shared_secrets = obj_Alloc( OBJ_CLASS_A_OBJ, 0 );

    /* Buggo: Should update accounting info to reflect */
    /* following chowns, once we -have- decent space   */
    /* accounting...                                   */
#ifdef OLD
    JOQ_P(run_q[0])->o.owner = o;	vm_Dirty(run_q[0]);
    JOQ_P(run_q[1])->o.owner = o;	vm_Dirty(run_q[1]);
    JOQ_P(run_q[2])->o.owner = o;	vm_Dirty(run_q[2]);
    JOQ_P(ps_q    )->o.owner = o;	vm_Dirty(ps_q);
    JOQ_P(pause_q )->o.owner = o;	vm_Dirty(pause_q);
    JOQ_P(halt_q  )->o.owner = o;	vm_Dirty(halt_q);
#endif

    JOQ_P(run_q[0])->o.objname = OBJ_FROM_BYT1('0');        vm_Dirty(run_q[0]);
    JOQ_P(run_q[1])->o.objname = OBJ_FROM_BYT1('1');        vm_Dirty(run_q[1]);
    JOQ_P(run_q[2])->o.objname = OBJ_FROM_BYT1('2');        vm_Dirty(run_q[2]);
    JOQ_P(ps_q    )->o.objname = OBJ_FROM_BYT2('p','s');    vm_Dirty(ps_q);
    JOQ_P(pause_q )->o.objname = OBJ_FROM_BYT3('p','o','z');vm_Dirty(pause_q);
    JOQ_P(halt_q  )->o.objname = OBJ_FROM_BYT3('h','l','t');vm_Dirty(halt_q);

    JOQ_P(run_q[0])->kind = OBJ_FROM_BYT3('r','u','n'); vm_Dirty(run_q[0]);
    JOQ_P(run_q[1])->kind = OBJ_FROM_BYT3('r','u','n'); vm_Dirty(run_q[1]);
    JOQ_P(run_q[2])->kind = OBJ_FROM_BYT3('r','u','n'); vm_Dirty(run_q[2]);
    JOQ_P(ps_q    )->kind = OBJ_FROM_BYT2('p','s'    ); vm_Dirty(ps_q    );
    JOQ_P(pause_q )->kind = OBJ_FROM_BYT3('p','o','z'); vm_Dirty(pause_q );
    JOQ_P(halt_q  )->kind = OBJ_FROM_BYT3('h','l','t'); vm_Dirty(halt_q );

    {   Usr_P p = USR_P(o);

	p->group		= OBJ_FROM_INT(0);
        p->lib			= obj_Lib;	/* Inherit std system pkgs. */
        p->byte_quota		= USR_USR_BYTE_QUOTA;
        p->bytes_owned		= OBJ_FROM_INT(sizeof(Usr_A_Header));
        p->object_quota		= USR_USR_OBJECT_QUOTA;
        p->objects_owned	= OBJ_FROM_INT(1);

	p->next			= OBJ_FROM_INT(0);
	p->prev			= OBJ_FROM_INT(0);
	p->this			= OBJ_FROM_INT(0);

	p->run_q[0]		= run_q[0];
	p->run_q[1]		= run_q[1];
	p->run_q[2]		= run_q[2];
	p->ps_q			= ps_q;
	p->pause_q		= pause_q;
	p->halt_q		= halt_q;

	p->time_slice		= OBJ_FROM_INT(0);

	p->default_package	= obj_Lib_Muf;

	p->do_signal		= OBJ_NIL;
	p->shell		= OBJ_NIL;
	p->telnet_daemon	= OBJ_NIL;
	p->text_editor		= OBJ_NIL;
	p->login_hints		= OBJ_NIL;
	p->config_fns		= OBJ_NIL;
	p->debugger		= OBJ_NIL;
	p->do_break		= OBJ_NIL;

	p->dbref_convert_errors	= OBJ_FROM_INT(0);

	p->encrypted_passphrase	= OBJ_FROM_BYT1('*');

	p->www			= OBJ_NIL;
	p->rank			= OBJ_FROM_INT(100);
	p->gagged		= OBJ_NIL;

	p->priv_bits		= OBJ_FROM_INT(0);

	p->doing		= OBJ_NIL;
	p->email		= OBJ_NIL;
	p->pgp_keyprint		= OBJ_NIL;
	p->homepage		= OBJ_NIL;
	p->do_not_disturb	= OBJ_NIL;
	p->nick_name		= OBJ_FROM_BYT0;
	p->long_name		= OBJ_NIL;
	p->true_name		= OBJ_NIL;
	p->hash_name		= OBJ_NIL;
	p->shared_secrets	= shared_secrets;
	p->original_nick_name	= OBJ_FROM_BYT0;
	p->last_long_name	= OBJ_NIL;
	p->last_true_name	= OBJ_NIL;
	p->last_hash_name	= OBJ_NIL;
	p->last_shared_secrets	= OBJ_NIL;
	p->date_of_last_name_change	= OBJ_FROM_INT(0);
	p->io_stream		= OBJ_NIL;
	p->ip0			= OBJ_NIL;
	p->ip1			= OBJ_NIL;
	p->ip2			= OBJ_NIL;
	p->ip3			= OBJ_NIL;
	p->port			= OBJ_NIL;
	p->user_version	= OBJ_FROM_INT(0);
	p->has_unknown_user_server	= OBJ_NIL;
	p->user_server_0	= OBJ_NIL;
	p->user_server_1	= OBJ_NIL;
	p->user_server_2	= OBJ_NIL;
	p->user_server_3	= OBJ_NIL;
	p->user_server_4	= OBJ_NIL;
	p->user_server_1_needs_updating	= OBJ_NIL;
	p->user_server_2_needs_updating	= OBJ_NIL;
	p->user_server_3_needs_updating	= OBJ_NIL;
	p->user_server_4_needs_updating	= OBJ_NIL;
	p->date_at_which_we_last_queried_user_servers = OBJ_FROM_INT(0);

	p->packet_preprocessor  = OBJ_FROM_INT(0);
	p->packet_postprocessor = OBJ_FROM_INT(0);
	p->first_used_by_muqnet = OBJ_FROM_INT(0);
	p->last_used_by_muqnet  = OBJ_FROM_INT(0);
	p->times_used_by_muqnet = OBJ_FROM_INT(0);

	{   int i;
	    for (i = USR_RESERVED_SLOTS;  i --> 0; ) p->reserved_slot[i] = OBJ_FROM_INT(0);
	}

	vm_Dirty(o);
    }
}



/************************************************************************/
/*-    invariants -- Sanity check on fn.				*/
/************************************************************************/

#if MUQ_DEBUG

static Vm_Int
invariants(
    FILE* f,
    char* t,
    Vm_Obj usr
) {
    /* First, check the basic directly */
    /* accessable job queues:          */
    Usr_A_Header u = *USR_P(usr);
    Vm_Unt       i;
    for (i = JOB_PRIORITY_LEVELS; i --> 0; ) {
	joq_Invariants( f,t, u.run_q[i] );
    }
    joq_Invariants( f,t, u.ps_q );
    joq_Invariants( f,t, u.pause_q );
    joq_Invariants( f,t, u.halt_q );

    /* Check 'kind' fields on special queues: */
    joq_Kind(f,t, u.ps_q,    OBJ_FROM_BYT2('p','s'    ) );
    joq_Kind(f,t, u.pause_q, OBJ_FROM_BYT3('p','o','z') );
    joq_Kind(f,t, u.halt_q,  OBJ_FROM_BYT3('h','l','t') );
    for (i = JOB_PRIORITY_LEVELS; i --> 0; ) {
	joq_Kind( f,t, u.run_q[i], OBJ_FROM_BYT3('r','u','n') );
    }

    /* Now, check every queue in which a job is found: */
    {	Joq_A_Link       orig = JOQ_P(u.ps_q)->link;
	Joq_A_Link this; this = orig; /* gcc won't let us merge these. */

	/* Check pointers in each link in job queue: */
	for (;;) {
	    this = joq_Get_Link( &this.next );
	    if (joq_Eq( &this, &orig ))   break;
	    joq_Invariants( f,t, this.this );
	}
    }

    return 0;
}

#endif




/************************************************************************/
/*-    usr_lib	              						*/
/************************************************************************/

static Vm_Obj
usr_lib(
    Vm_Obj o
) {
    return U(o)->lib;
}



/************************************************************************/
/*-    usr_byte_quota                 					*/
/************************************************************************/

static Vm_Obj
usr_byte_quota(
    Vm_Obj o
) {
    return U(o)->byte_quota;
}



/************************************************************************/
/*-    usr_bytes_owned                 					*/
/************************************************************************/

static Vm_Obj
usr_bytes_owned(
    Vm_Obj o
) {
    if (o == job_RunState.j.acting_user) {
        return OBJ_FROM_UNT( job_RunState.bytes_owned );
    }
    return U(o)->bytes_owned;
}



/************************************************************************/
/*-    usr_object_quota                 				*/
/************************************************************************/

static Vm_Obj
usr_object_quota(
    Vm_Obj o
) {
    return U(o)->object_quota;
}



/************************************************************************/
/*-    usr_objects_owned                 				*/
/************************************************************************/

static Vm_Obj
usr_objects_owned(
    Vm_Obj o
) {
    if (o == job_RunState.j.acting_user) {
        return OBJ_FROM_UNT( job_RunState.objects_owned );
    }
    return U(o)->objects_owned;
}



/************************************************************************/
/*-    usr_do_break	              					*/
/************************************************************************/

static Vm_Obj
usr_do_break(
    Vm_Obj o
) {
    return U(o)->do_break;
}

/************************************************************************/
/*-    usr_debugger              					*/
/************************************************************************/

static Vm_Obj
usr_debugger(
    Vm_Obj o
) {
    return U(o)->debugger;
}

/************************************************************************/
/*-    usr_break_disable             					*/
/************************************************************************/

static Vm_Obj
usr_break_disable(
    Vm_Obj o
) {
    return U(o)->break_disable;
}

/************************************************************************/
/*-    usr_break_enable             					*/
/************************************************************************/

static Vm_Obj
usr_break_enable(
    Vm_Obj o
) {
    return U(o)->break_enable;
}

/************************************************************************/
/*-    usr_break_on_signal             					*/
/************************************************************************/

static Vm_Obj
usr_break_on_signal(
    Vm_Obj o
) {
    return U(o)->break_on_signal;
}

/************************************************************************/
/*-    usr_dbref_convert_errors        					*/
/************************************************************************/

static Vm_Obj
usr_dbref_convert_errors(
    Vm_Obj o
) {
    return U(o)->dbref_convert_errors;
}

/************************************************************************/
/*-    usr_do_signal              					*/
/************************************************************************/

static Vm_Obj
usr_do_signal(
    Vm_Obj o
) {
    return U(o)->do_signal;
}

/************************************************************************/
/*-    usr_do_not_disturb              					*/
/************************************************************************/

static Vm_Obj
usr_do_not_disturb(
    Vm_Obj o
) {
    return U(o)->do_not_disturb;
}

/************************************************************************/
/*-    usr_doing	              					*/
/************************************************************************/

static Vm_Obj
usr_doing(
    Vm_Obj o
) {
    return U(o)->doing;
}

/************************************************************************/
/*-    usr_email	              					*/
/************************************************************************/

static Vm_Obj
usr_email(
    Vm_Obj o
) {
    return U(o)->email;
}

/************************************************************************/
/*-    usr_pgp_keyprint	              					*/
/************************************************************************/

static Vm_Obj
usr_pgp_keyprint(
    Vm_Obj o
) {
    return U(o)->pgp_keyprint;
}

/************************************************************************/
/*-    usr_homepage	              					*/
/************************************************************************/

static Vm_Obj
usr_homepage(
    Vm_Obj o
) {
    return U(o)->homepage;
}



/************************************************************************/
/*-    usr_pause_queue             					*/
/************************************************************************/

static Vm_Obj
usr_pause_queue(
    Vm_Obj o
) {
    return U(o)->pause_q;
}

/************************************************************************/
/*-    usr_ps_queue             					*/
/************************************************************************/

static Vm_Obj
usr_ps_queue(
    Vm_Obj o
) {
    return U(o)->ps_q;
}

/************************************************************************/
/*-    usr_run_queue_0             					*/
/************************************************************************/

static Vm_Obj
usr_run_queue_0(
    Vm_Obj o
) {
    return U(o)->run_q[0];
}

/************************************************************************/
/*-    usr_run_queue_1             					*/
/************************************************************************/

static Vm_Obj
usr_run_queue_1(
    Vm_Obj o
) {
    return U(o)->run_q[1];
}

/************************************************************************/
/*-    usr_run_queue_2             					*/
/************************************************************************/

static Vm_Obj
usr_run_queue_2(
    Vm_Obj o
) {
    return U(o)->run_q[2];
}

/************************************************************************/
/*-    usr_halt_queue             					*/
/************************************************************************/

static Vm_Obj
usr_halt_queue(
    Vm_Obj o
) {
    return U(o)->halt_q;
}

/************************************************************************/
/*-    usr_group          						*/
/************************************************************************/

static Vm_Obj
usr_group(
    Vm_Obj o
) {
    return USR_P(o)->group;
}



/************************************************************************/
/*-    usr_package              					*/
/************************************************************************/

static Vm_Obj
usr_package(
    Vm_Obj o
) {
    return U(o)->default_package;
}

/************************************************************************/
/*-    usr_shell	              					*/
/************************************************************************/

static Vm_Obj
usr_shell(
    Vm_Obj o
) {
    return U(o)->shell;
}

/************************************************************************/
/*-    usr_telnet_daemon              					*/
/************************************************************************/

static Vm_Obj
usr_telnet_daemon(
    Vm_Obj o
) {
    return U(o)->telnet_daemon;
}

/************************************************************************/
/*-    usr_text_editor	              					*/
/************************************************************************/

static Vm_Obj
usr_text_editor(
    Vm_Obj o
) {
    return U(o)->text_editor;
}

/************************************************************************/
/*-    usr_login_hints	              					*/
/************************************************************************/

static Vm_Obj
usr_login_hints(
    Vm_Obj o
) {
    return U(o)->login_hints;
}

/************************************************************************/
/*-    usr_config_fns	              					*/
/************************************************************************/

static Vm_Obj
usr_config_fns(
    Vm_Obj o
) {
    return U(o)->config_fns;
}

/************************************************************************/
/*-    usr_time_slice	              					*/
/************************************************************************/

static Vm_Obj
usr_time_slice(
    Vm_Obj o
) {
    return U(o)->time_slice;
}

/************************************************************************/
/*-    usr_encrypted_passphrase        					*/
/************************************************************************/

static Vm_Obj
usr_encrypted_passphrase(
    Vm_Obj o
) {
    return U(o)->encrypted_passphrase;
}

/************************************************************************/
/*-    usr_gagged          						*/
/************************************************************************/

static Vm_Obj
usr_gagged(
    Vm_Obj o
) {
    return U(o)->gagged;
}

/************************************************************************/
/*-    usr_priv_bits          						*/
/************************************************************************/

static Vm_Obj
usr_priv_bits(
    Vm_Obj o
) {
    return U(o)->priv_bits;
}

/************************************************************************/
/*-    usr_avatar_opengl       						*/
/************************************************************************/

static Vm_Obj
usr_avatar_opengl(
    Vm_Obj o
) {
    Vm_Int privs = OBJ_TO_INT( U(o)->priv_bits );
    return OBJ_FROM_BOOL( (privs & USR_AVATAR_OPENGL) != 0 );
}

/************************************************************************/
/*-    usr_unrestricted_opengl 						*/
/************************************************************************/

static Vm_Obj
usr_unrestricted_opengl(
    Vm_Obj o
) {
    Vm_Int privs = OBJ_TO_INT( U(o)->priv_bits );
    return OBJ_FROM_BOOL( (privs & USR_UNRESTRICTED_OPENGL) != 0 );
}


/************************************************************************/
/*-    usr_rank          						*/
/************************************************************************/

static Vm_Obj
usr_rank(
    Vm_Obj o
) {
    return U(o)->rank;
}

/************************************************************************/
/*-    usr_www          						*/
/************************************************************************/

static Vm_Obj
usr_www(
    Vm_Obj o
) {
    return U(o)->www;
}

/************************************************************************/
/*-    usr_nick_name          						*/
/************************************************************************/

static Vm_Obj
usr_nick_name(
    Vm_Obj o
) {
    return U(o)->nick_name;
}

/************************************************************************/
/*-    usr_long_name          						*/
/************************************************************************/

static Vm_Obj
usr_long_name(
    Vm_Obj o
) {
    return U(o)->long_name;
}

/************************************************************************/
/*-    usr_last_long_name      						*/
/************************************************************************/

static Vm_Obj
usr_last_long_name(
    Vm_Obj o
) {
    return U(o)->last_long_name;
}

/************************************************************************/
/*-    usr_true_name          						*/
/************************************************************************/

static Vm_Obj
usr_true_name(
    Vm_Obj o
) {
    /* Let's be paranoid about true names.  REALLY paranoid: */
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
        return U(o)->true_name;
    } else {
        return OBJ_NIL;
    }
}

/************************************************************************/
/*-    usr_last_true_name      						*/
/************************************************************************/

static Vm_Obj
usr_last_true_name(
    Vm_Obj o
) {
    /* Let's be paranoid about true names.  REALLY paranoid: */
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
        return U(o)->last_true_name;
    } else {
        return OBJ_NIL;
    }
}

/************************************************************************/
/*-    usr_hash_name          						*/
/************************************************************************/

static Vm_Obj
usr_hash_name(
    Vm_Obj o
) {
    return U(o)->hash_name;
}

/************************************************************************/
/*-    usr_last_hash_name      						*/
/************************************************************************/

static Vm_Obj
usr_last_hash_name(
    Vm_Obj o
) {
    return U(o)->last_hash_name;
}

/************************************************************************/
/*-    usr_shared_secrets      						*/
/************************************************************************/

static Vm_Obj
usr_shared_secrets(
    Vm_Obj o
) {
    /* Let's be paranoid about shared secrets.  REALLY paranoid: */
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
        return U(o)->shared_secrets;
    } else {
        return OBJ_NIL;
    }
}

/************************************************************************/
/*-    usr_last_shared_secrets  					*/
/************************************************************************/

static Vm_Obj
usr_last_shared_secrets(
    Vm_Obj o
) {
    /* Let's be paranoid about shared secrets.  REALLY paranoid: */
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
        return U(o)->last_shared_secrets;
    } else {
        return OBJ_NIL;
    }
}

/************************************************************************/
/*-    usr_original_nick_name						*/
/************************************************************************/

static Vm_Obj
usr_original_nick_name(
    Vm_Obj o
) {
    return U(o)->original_nick_name;
}

/************************************************************************/
/*-    usr_date_of_last_name_change					*/
/************************************************************************/

static Vm_Obj
usr_date_of_last_name_change(
    Vm_Obj o
) {
/* buggo, this will always be zero at present. */
/* when we implement rotation of trueName &tc, */
/* probably at roughly 1-month intervals, we   */
/* should hack this variable to be automatically */
/* updated when we modify the last* props:     */
    return U(o)->date_of_last_name_change;
}

/************************************************************************/
/*-    usr_ip0		      						*/
/************************************************************************/

static Vm_Obj
usr_ip0(
    Vm_Obj o
) {
    return U(o)->ip0;
}

/************************************************************************/
/*-    usr_ip1		      						*/
/************************************************************************/

static Vm_Obj
usr_ip1(
    Vm_Obj o
) {
    return U(o)->ip1;
}

/************************************************************************/
/*-    usr_ip2		      						*/
/************************************************************************/

static Vm_Obj
usr_ip2(
    Vm_Obj o
) {
    return U(o)->ip2;
}

/************************************************************************/
/*-    usr_ip3		      						*/
/************************************************************************/

static Vm_Obj
usr_ip3(
    Vm_Obj o
) {
    return U(o)->ip3;
}

/************************************************************************/
/*-    usr_port		      						*/
/************************************************************************/

static Vm_Obj
usr_port(
    Vm_Obj o
) {
    return U(o)->port;
}

/************************************************************************/
/*-    usr_io_stream	      						*/
/************************************************************************/

static Vm_Obj
usr_io_stream(
    Vm_Obj o
) {
    return U(o)->io_stream;
}

/************************************************************************/
/*-    usr_user_server_0   						*/
/************************************************************************/

static Vm_Obj
usr_user_server_0(
    Vm_Obj o
) {
    return U(o)->user_server_0;
}

/************************************************************************/
/*-    usr_user_server_1   						*/
/************************************************************************/

static Vm_Obj
usr_user_server_1(
    Vm_Obj o
) {
    return U(o)->user_server_1;
}

/************************************************************************/
/*-    usr_user_server_2   						*/
/************************************************************************/

static Vm_Obj
usr_user_server_2(
    Vm_Obj o
) {
    return U(o)->user_server_2;
}

/************************************************************************/
/*-    usr_user_server_3   						*/
/************************************************************************/

static Vm_Obj
usr_user_server_3(
    Vm_Obj o
) {
    return U(o)->user_server_3;
}

/************************************************************************/
/*-    usr_user_server_4   						*/
/************************************************************************/

static Vm_Obj
usr_user_server_4(
    Vm_Obj o
) {
    return U(o)->user_server_4;
}

/************************************************************************/
/*-    usr_user_server_1_needs_updating					*/
/************************************************************************/

static Vm_Obj
usr_user_server_1_needs_updating(
    Vm_Obj o
) {
    return U(o)->user_server_1_needs_updating;
}

/************************************************************************/
/*-    usr_user_server_2_needs_updating					*/
/************************************************************************/

static Vm_Obj
usr_user_server_2_needs_updating(
    Vm_Obj o
) {
    return U(o)->user_server_2_needs_updating;
}

/************************************************************************/
/*-    usr_user_server_3_needs_updating					*/
/************************************************************************/

static Vm_Obj
usr_user_server_3_needs_updating(
    Vm_Obj o
) {
    return U(o)->user_server_3_needs_updating;
}

/************************************************************************/
/*-    usr_user_server_4_needs_updating					*/
/************************************************************************/

static Vm_Obj
usr_user_server_4_needs_updating(
    Vm_Obj o
) {
    return U(o)->user_server_4_needs_updating;
}

/************************************************************************/
/*-    usr_has_unkown_user_server					*/
/************************************************************************/

static Vm_Obj
usr_has_unknown_user_server(
    Vm_Obj o
) {
    return U(o)->has_unknown_user_server;
}

/************************************************************************/
/*-    usr_user_version   						*/
/************************************************************************/

static Vm_Obj
usr_user_version(
    Vm_Obj o
) {
    return U(o)->user_version;
}

/************************************************************************/
/*-    usr_date_at_which_we_last_queried_user_servers			*/
/************************************************************************/

static Vm_Obj
usr_date_at_which_we_last_queried_user_servers(
    Vm_Obj o
) {
    return U(o)->date_at_which_we_last_queried_user_servers;
}

/************************************************************************/
/*-    usr_packet_preprocessor						*/
/************************************************************************/

static Vm_Obj
usr_packet_preprocessor(
    Vm_Obj o
) {
    return U(o)->packet_preprocessor;
}

/************************************************************************/
/*-    usr_packet_postprocessor						*/
/************************************************************************/

static Vm_Obj
usr_packet_postprocessor(
    Vm_Obj o
) {
    return U(o)->packet_postprocessor;
}

/************************************************************************/
/*-    usr_first_used_by_muqnet						*/
/************************************************************************/

static Vm_Obj
usr_first_used_by_muqnet(
    Vm_Obj o
) {
    return U(o)->first_used_by_muqnet;
}

/************************************************************************/
/*-    usr_last_used_by_muqnet						*/
/************************************************************************/

static Vm_Obj
usr_last_used_by_muqnet(
    Vm_Obj o
) {
    return U(o)->last_used_by_muqnet;
}


/************************************************************************/
/*-    usr_times_used_by_muqnet						*/
/************************************************************************/

static Vm_Obj
usr_times_used_by_muqnet(
    Vm_Obj o
) {
    return U(o)->times_used_by_muqnet;
}


/************************************************************************/
/*-    note_user_servers_need_updating					*/
/************************************************************************/

static void
note_user_servers_need_updating(
    Vm_Obj o
) {
    {   Usr_P  p = USR_P(o);

	p->user_server_1_needs_updating = OBJ_FROM_INT(0);
	p->user_server_2_needs_updating = OBJ_FROM_INT(0);
	p->user_server_3_needs_updating = OBJ_FROM_INT(0);
	p->user_server_4_needs_updating = OBJ_FROM_INT(0);

	p->user_version = OBJ_FROM_INT( OBJ_TO_INT(p->user_version) +1 );
    }
    vm_Dirty(o);
}

/************************************************************************/
/*-    usr_set_nick_name	      					*/
/************************************************************************/

static Vm_Obj
usr_set_nick_name(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
	if (stg_Is_Stg(v)) {
	    U(o)->nick_name = v;
	    vm_Dirty(o);
	}
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_long_name	      					*/
/************************************************************************/

static Vm_Obj
usr_set_long_name(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
/* buggo Comparison should prolly really be obj_Neql: */
        if (U(o)->long_name != v) {
	    U(o)->long_name = v;
	    vm_Dirty(o);
	    note_user_servers_need_updating(o);
	}
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_last_long_name	      					*/
/************************************************************************/

static Vm_Obj
usr_set_last_long_name(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
/* buggo Comparison should prolly really be obj_Neql: */
        if (U(o)->last_long_name != v) {
	    U(o)->last_long_name = v;
	    vm_Dirty(o);
	    note_user_servers_need_updating(o);
	}
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_true_name	      					*/
/************************************************************************/

static Vm_Obj
usr_set_true_name(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
	if (U(o)->true_name != v) {
	    U(o)->true_name = v;
	    vm_Dirty(o);
	    note_user_servers_need_updating(o);
	}
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_last_true_name	      					*/
/************************************************************************/

static Vm_Obj
usr_set_last_true_name(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
	if (U(o)->last_true_name != v) {
	    U(o)->last_true_name = v;
	    vm_Dirty(o);
	    note_user_servers_need_updating(o);
	}
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_hash_name	      					*/
/************************************************************************/

static Vm_Obj
usr_set_hash_name(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
	if (OBJ_IS_INT(v)) {
	    if (U(o)->hash_name != v) {
		U(o)->hash_name = v;
		vm_Dirty(o);
		note_user_servers_need_updating(o);
	    }
	}
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_last_hash_name	      					*/
/************************************************************************/

static Vm_Obj
usr_set_last_hash_name(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
	if (OBJ_IS_INT(v)) {
	    if (U(o)->last_hash_name != v) {
		U(o)->last_hash_name = v;
		vm_Dirty(o);
		note_user_servers_need_updating(o);
	    }
	}
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_shared_secrets	      					*/
/************************************************************************/

static Vm_Obj
usr_set_shared_secrets(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
        U(o)->shared_secrets = v;
        vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_original_nick_name	      				*/
/************************************************************************/

static Vm_Obj
usr_set_original_nick_name(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
	if (stg_Is_Stg(v)) {
	    U(o)->original_nick_name = v;
	    vm_Dirty(o);
	}
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_last_shared_secrets	      					*/
/************************************************************************/

static Vm_Obj
usr_set_last_shared_secrets(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
        U(o)->last_shared_secrets = v;
        vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_ip0		      					*/
/************************************************************************/

static Vm_Obj
usr_set_ip0(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
	if (OBJ_IS_INT(v)) {
	    if (U(o)->ip0 != v) {
		U(o)->ip0 = v;
		vm_Dirty(o);
		note_user_servers_need_updating(o);
	    }
	}
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_ip1		      					*/
/************************************************************************/

static Vm_Obj
usr_set_ip1(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
	if (OBJ_IS_INT(v)) {
	    if (U(o)->ip1 != v) {
		U(o)->ip1 = v;
		vm_Dirty(o);
		note_user_servers_need_updating(o);
	    }
	}
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_ip2		      					*/
/************************************************************************/

static Vm_Obj
usr_set_ip2(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
	if (OBJ_IS_INT(v)) {
	    if (U(o)->ip2 != v) {
		U(o)->ip2 = v;
		vm_Dirty(o);
		note_user_servers_need_updating(o);
	    }
	}
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_ip3		      					*/
/************************************************************************/

static Vm_Obj
usr_set_ip3(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
	if (OBJ_IS_INT(v)) {
	    if (U(o)->ip3 != v) {
		U(o)->ip3 = v;
		vm_Dirty(o);
		note_user_servers_need_updating(o);
	    }
	}
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_port		      					*/
/************************************************************************/

static Vm_Obj
usr_set_port(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
	if (OBJ_IS_INT(v)) {
	    if (U(o)->port != v) {
		U(o)->port = v;
		vm_Dirty(o);
		note_user_servers_need_updating(o);
	    }
	}
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_io_stream	      					*/
/************************************************************************/

static Vm_Obj
usr_set_io_stream(
    Vm_Obj o,
    Vm_Obj v
) {
    if (U(o)->io_stream != v) {
	U(o)->io_stream  = v;
	vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_user_server_0      					*/
/************************************************************************/

static Vm_Obj
usr_set_user_server_0(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
	U(o)->user_server_0 = v;
	vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_user_server_1      					*/
/************************************************************************/

static Vm_Obj
usr_set_user_server_1(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->user_server_1 = v;
    U(o)->user_server_1_needs_updating = OBJ_FROM_INT(0);
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_user_server_2      					*/
/************************************************************************/

static Vm_Obj
usr_set_user_server_2(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->user_server_2 = v;
    U(o)->user_server_2_needs_updating = OBJ_FROM_INT(0);
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_user_server_3      					*/
/************************************************************************/

static Vm_Obj
usr_set_user_server_3(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->user_server_3 = v;
    U(o)->user_server_3_needs_updating = OBJ_FROM_INT(0);
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_user_server_4      					*/
/************************************************************************/

static Vm_Obj
usr_set_user_server_4(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->user_server_4 = v;
    U(o)->user_server_4_needs_updating = OBJ_FROM_INT(0);
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_user_server_1_needs_updating				*/
/************************************************************************/

static Vm_Obj
usr_set_user_server_1_needs_updating(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
	U(o)->user_server_1_needs_updating = v;
	vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_user_server_2_needs_updating				*/
/************************************************************************/

static Vm_Obj
usr_set_user_server_2_needs_updating(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
	U(o)->user_server_2_needs_updating = v;
	vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_user_server_3_needs_updating				*/
/************************************************************************/

static Vm_Obj
usr_set_user_server_3_needs_updating(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
	U(o)->user_server_3_needs_updating = v;
	vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_user_server_4_needs_updating				*/
/************************************************************************/

static Vm_Obj
usr_set_user_server_4_needs_updating(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
	U(o)->user_server_4_needs_updating = v;
	vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_has_unknown_user_server 					*/
/************************************************************************/

static Vm_Obj
usr_set_has_unknown_user_server(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
	U(o)->has_unknown_user_server = v;
	vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_user_version      					*/
/************************************************************************/

static Vm_Obj
usr_set_user_version(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
	if (OBJ_IS_INT(v)) {
	    U(o)->user_version = v;
	    vm_Dirty(o);
	}
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_packet_preprocessor     					*/
/************************************************************************/

static Vm_Obj
usr_set_packet_preprocessor(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->packet_preprocessor = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_packet_postprocessor    					*/
/************************************************************************/

static Vm_Obj
usr_set_packet_postprocessor(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->packet_postprocessor = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_date_at_which_we_last_queried_user_servers		*/
/************************************************************************/

static Vm_Obj
usr_set_date_at_which_we_last_queried_user_servers(
    Vm_Obj o,
    Vm_Obj v
) {
    if ((job_RunState.j.privs & JOB_PRIVS_OMNIPOTENT)
    &&   OBJ_IS_CLASS_ROT(job_RunState.j.acting_user)
    ){
	if (OBJ_IS_INT(v)) {
	    U(o)->date_at_which_we_last_queried_user_servers = v;
	    vm_Dirty(o);
	}
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}


/************************************************************************/
/*-    usr_set_gagged		      					*/
/************************************************************************/

static Vm_Obj
usr_set_gagged(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->gagged = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_priv_bits	      					*/
/************************************************************************/

static Vm_Obj
usr_set_priv_bits(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
        U(o)->priv_bits = v;
        vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_avatar_opengl	      					*/
/************************************************************************/

static Vm_Obj
usr_set_avatar_opengl(
    Vm_Obj o,
    Vm_Obj v
) {
    Vm_Int privs = OBJ_TO_INT( U(o)->priv_bits );
    privs &= ~USR_AVATAR_OPENGL;
    if (v != OBJ_NIL) privs |= USR_AVATAR_OPENGL;
    U(o)->priv_bits = OBJ_FROM_INT( privs ); vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_unrestricted_opengl					*/
/************************************************************************/

static Vm_Obj
usr_set_unrestricted_opengl(
    Vm_Obj o,
    Vm_Obj v
) {
    Vm_Int privs = OBJ_TO_INT( U(o)->priv_bits );
    privs &= ~USR_UNRESTRICTED_OPENGL;
    if (v != OBJ_NIL) privs |= USR_UNRESTRICTED_OPENGL;
    U(o)->priv_bits = OBJ_FROM_INT( privs ); vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_rank		      					*/
/************************************************************************/

static Vm_Obj
usr_set_rank(
    Vm_Obj o,
    Vm_Obj v
) {
    if (OBJ_IS_INT(v)) {
	U(o)->rank = v;
	vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_www		      					*/
/************************************************************************/

static Vm_Obj
usr_set_www(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->www = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_encrypted_passphrase    					*/
/************************************************************************/

static Vm_Obj
usr_set_encrypted_passphrase(
    Vm_Obj o,
    Vm_Obj v
) {
    if (stg_Is_Stg(v)) {
	U(o)->encrypted_passphrase = v;
	vm_Dirty(o);
    }

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_break_disable           					*/
/************************************************************************/

static Vm_Obj
usr_set_break_disable(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->break_disable = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_break_enable           					*/
/************************************************************************/

static Vm_Obj
usr_set_break_enable(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->break_enable = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_break_on_signal         					*/
/************************************************************************/

static Vm_Obj
usr_set_break_on_signal(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->break_on_signal = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_do_break             					*/
/************************************************************************/

static Vm_Obj
usr_set_do_break(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->do_break = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_debugger             					*/
/************************************************************************/

static Vm_Obj
usr_set_debugger(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->debugger = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_do_signal             					*/
/************************************************************************/

static Vm_Obj
usr_set_do_signal(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->do_signal = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_do_not_disturb          					*/
/************************************************************************/

static Vm_Obj
usr_set_do_not_disturb(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->do_not_disturb = v;
    vm_Dirty(o);
    note_user_servers_need_updating(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_doing          						*/
/************************************************************************/

static Vm_Obj
usr_set_doing(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->doing = v;
    vm_Dirty(o);
    note_user_servers_need_updating(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_homepage        						*/
/************************************************************************/

static Vm_Obj
usr_set_homepage(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->homepage = v;
    vm_Dirty(o);
    note_user_servers_need_updating(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_email        						*/
/************************************************************************/

static Vm_Obj
usr_set_email(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->email = v;
    vm_Dirty(o);
    note_user_servers_need_updating(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_pgp_keyprint    						*/
/************************************************************************/

static Vm_Obj
usr_set_pgp_keyprint(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->pgp_keyprint = v;
    vm_Dirty(o);
    note_user_servers_need_updating(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    usr_set_package              					*/
/************************************************************************/

static Vm_Obj
usr_set_package(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->default_package = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    usr_set_group        						*/
/************************************************************************/

static Vm_Obj
usr_set_group(
    Vm_Obj o,
    Vm_Obj v
) {
/* BUGGO: Need some validity checks here... */
    USR_P(o)->group = v;
    vm_Dirty(o);
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_lib	             					*/
/************************************************************************/

static Vm_Obj
usr_set_lib(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->lib = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    usr_set_byte_quota            					*/
/************************************************************************/

static Vm_Obj
usr_set_byte_quota(
    Vm_Obj o,
    Vm_Obj v
) {
/* buggo, need typecheck on v */
    if (o == job_RunState.j.acting_user) {
        job_RunState.byte_quota = OBJ_TO_UNT( v );
	return (Vm_Obj) 0;
    }
    U(o)->byte_quota = v;
    vm_Dirty(o);
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    usr_set_bytes_owned           					*/
/************************************************************************/

static Vm_Obj
usr_set_bytes_owned(
    Vm_Obj o,
    Vm_Obj v
) {
/* buggo, need typecheck on v */
    if (o == job_RunState.j.acting_user) {
        job_RunState.bytes_owned = OBJ_TO_UNT( v );
	return (Vm_Obj) 0;
    }
    U(o)->bytes_owned = v;
    vm_Dirty(o);
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    usr_set_object_quota            					*/
/************************************************************************/

static Vm_Obj
usr_set_object_quota(
    Vm_Obj o,
    Vm_Obj v
) {
/* buggo, need typecheck on v */
    if (o == job_RunState.j.acting_user) {
        job_RunState.object_quota = OBJ_TO_UNT( v );
	return (Vm_Obj) 0;
    }
    U(o)->object_quota = v;
    vm_Dirty(o);
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}



/************************************************************************/
/*-    usr_set_objects_owned           					*/
/************************************************************************/

static Vm_Obj
usr_set_objects_owned(
    Vm_Obj o,
    Vm_Obj v
) {
/* buggo, need typecheck on v */
    if (o == job_RunState.j.acting_user) {
        job_RunState.objects_owned = OBJ_TO_UNT( v );
	return (Vm_Obj) 0;
    }
    U(o)->objects_owned = v;
    vm_Dirty(o);
    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_shell             					*/
/************************************************************************/

static Vm_Obj
usr_set_shell(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->shell = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_telnet_daemon           					*/
/************************************************************************/

static Vm_Obj
usr_set_telnet_daemon(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->telnet_daemon = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_text_editor             					*/
/************************************************************************/

static Vm_Obj
usr_set_text_editor(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->text_editor = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_login_hints             					*/
/************************************************************************/

static Vm_Obj
usr_set_login_hints(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->login_hints = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_config_fns             					*/
/************************************************************************/

static Vm_Obj
usr_set_config_fns(
    Vm_Obj o,
    Vm_Obj v
) {
    U(o)->config_fns = v;
    vm_Dirty(o);

    /* Don't store to propdir: */
    return (Vm_Obj) 0;
}

/************************************************************************/
/*-    usr_set_never	 						*/
/************************************************************************/

static Vm_Obj
usr_set_never(
    Vm_Obj o,
    Vm_Obj v
) {
    return (Vm_Obj) 0;
}




/************************************************************************/
/*-    --- Static fns ---						*/
/************************************************************************/



/************************************************************************/
/*-    sizeof_usr -- Return size of user object.			*/
/************************************************************************/

static Vm_Unt
sizeof_usr(
    Vm_Unt size
) {
    return sizeof( Usr_A_Header );
}






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

@end example
