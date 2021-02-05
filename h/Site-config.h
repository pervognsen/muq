
/*--   Site-config.h -- Local customizations for Muq.			*/
/* This file is formatted for emacs' outline-minor-mode.		*/

#ifndef INCLUDED_SITE_CONFIG_H
#define INCLUDED_SITE_CONFIG_H



/************************************************************************/
/*									*/
/* This file exists to hold site-specific #defines.			*/
/* As far as practical, I've tried to structure Muq			*/
/* so that you can do all customizations by merely			*/
/* adding #defines to this file.  That way, when a			*/
/* new version of Muq comes out, you can configure			*/
/* it correctly for your site merely by copying this			*/
/* file into the new distribution, and compiling.			*/
/*									*/
/* To make this work, all macros in Muq which can			*/
/* reasonably be customized by the user are defined			*/
/* by code like:							*/
/*									*/
/*	#ifndef MUQ_NEAT_OPTION						*/
/*	#define MUQ_NEAT_OPTION	"Cool!!"				*/
/*	#endif  MUQ_NEAT_OPTION						*/
/*									*/
/* This avoids cluttering a central configuration file			*/
/* with zillions of obscure options from unrelated and			*/
/* possibly optional code modules (an ugly setup from a			*/
/* modularity point of view) but still allows you to			*/
/* override these distributed default values with this			*/
/* one central site-specific configuration file.			*/
/*									*/
/* SO: If you find macros in Defaults.h or anywhere else		*/
/* that you would like to customize, by all means do so,		*/
/* >>BUT<< please, to keep life simple for everyone, do			*/
/* so by adding #defines HERE, not by modifying other			*/
/* files.								*/
/*									*/
/* If the other files aren't written to allow this,			*/
/* that is a BUG, and should be reported as one; I will			*/
/* fix the problem in the next release.					*/
/*									*/
/* Note: Values set in this file should also use the			*/
/*									*/
/*	#ifndef MUQ_NEAT_OPTION						*/
/*	#define MUQ_NEAT_OPTION	"Cool!!"				*/
/*	#endif  MUQ_NEAT_OPTION						*/
/*									*/
/* format.  This allows overriding of them on the commandline.		*/
/*									*/
/* For example, the selftest suite takes advantage of this to		*/
/* set unrealistically small values for some parameters during		*/
/* torture tests.                                              		*/
/*									*/
/************************************************************************/



/************************************************************************/
/*-    File variables							*/
#endif /* INCLUDED_SITE_CONFIG_H */
/*

Local variables:
mode: outline-minor
outline-regexp: "[ \\t]*\/\\*-"
End:
*/

