% -*- mode: LaTeX -*-

%% For double-blind review submission, w/o CCS and ACM Reference (max submission space)
%\documentclass[acmsmall,review,anonymous,natbib=false]{acmart}\settopmatter{printfolios=true,printccs=false,printacmref=false}
%% For double-blind review submission, w/ CCS and ACM Reference
%\documentclass[acmsmall,review,anonymous]{acmart}\settopmatter{printfolios=true}
%% For single-blind review submission, w/o CCS and ACM Reference (max submission space)
%\documentclass[acmsmall,review,anonymous]{acmart}\settopmatter{printfolios=true,printccs=false,printacmref=false}
%% For single-blind review submission, w/ CCS and ACM Reference
%\documentclass[acmsmall,review]{acmart}\settopmatter{printfolios=true}
%% For final camera-ready submission, w/ required CCS and ACM Reference
%\documentclass[acmsmall,screen]{acmart}\settopmatter{}

% https://github.com/borisveytsman/acmart/issues/406#issuecomment-667180341
\PassOptionsToPackage{prologue,dvipsnames}{xcolor}

\documentclass[acmsmall,review]{acmart}\settopmatter{printfolios=true,printccs=false,printacmref=false}

%% Journal information
%%
\setcopyright{rightsretained}
\acmPrice{}
\acmDOI{10.1145/1111111}
\acmYear{2024}
\copyrightyear{2024}
%\acmSubmissionID{popl24main-p11-p}
\acmJournal{PACMPL}
\acmVolume{1}
\acmNumber{ICFP}
\acmArticle{1}
\acmMonth{1}

%% Bibliography style
\bibliographystyle{ACM-Reference-Format}
%% Citation style
%% Note: author/year citations are required for papers published as an
%% issue of PACMPL.
\citestyle{acmauthoryear}   %% For author/year citations

% Some conditional build stuff for handling the Appendix

\newif\ifmain
\newif\ifappendix

% Builds only the main paper by default.
\maintrue
\appendixfalse
% But we provide a switch to build the Appendix only.
\def\appendixonly{\mainfalse{}\appendixtrue{}}

% .. so that you can comment out the following line to build the Appendix only
% This is done by the `make appendix.pdf` target.
%\appendixonly

% Same thing for an extended version that includes the Appendix
\def\extended{\maintrue{}\appendixtrue{}}
%\extended

%%%%%%%

\ifappendix
\usepackage[appendix=inline]{apxproof}
\else
\usepackage[appendix=append]{apxproof}
\fi
%\usepackage{array} % \newcolumntype
\usepackage{enumitem} % label=(\alph*)
\usepackage{ifdraft}
\usepackage[nameinlink]{cleveref}
\usepackage{xspace}
\usepackage{url}
\usepackage{varwidth}
\usepackage{galois}
%\usepackage{hsyl-listing} % listing style, hsyl-style
%\usepackage{scalerel}
%\usepackage[all]{xy}
\usepackage{relsize} % relscale
\usepackage{xfp} % fpeval
%\usepackage{stackengine}
\usepackage{mathtools} % xhookrightarrow
\usepackage{trimclip} % clipbox
\usepackage{mathpartir} % inference rules
\usepackage{subcaption}
\usepackage{witharrows}
\usepackage{mathbbol} % \bbcolon and \bbquestionmark
%\usepackage{stmaryrd} % \lightning
%\usepackage{tikz}
%\usetikzlibrary{cd} % commutative diagrams
%\usetikzlibrary{calc}
%\usetikzlibrary{fit}
%\usetikzlibrary{patterns}
%\usetikzlibrary{matrix}
%\usetikzlibrary{decorations.pathreplacing}
%\usetikzlibrary{decorations.pathmorphing}
%\usetikzlibrary{profiler}
%\usepackage{placeins} % flush floats with \FloatBarrier
\usepackage[T1]{fontenc} % https://tex.stackexchange.com/a/181119

\usepackage{utf8-symbols}
\input{macros}

\ifnonanon{\usepackage[mark]{gitinfo2}}

%include custom.fmt
\newcommand{\keyword}[1]{\textcolor{BlueViolet}{\textbf{#1}}}
\newcommand{\id}[1]{\textsf{\textsl{#1}}}
\newcommand{\varcolor}[1]{{\color{Sepia} #1}}
\newcommand{\concolor}[1]{{\color{OliveGreen} #1}}
\newcommand{\varid}[1]{\varcolor{\id{#1}}}
\newcommand{\conid}[1]{\concolor{\id{#1}}}
%\newcommand{\tick}{\text{\textquoteright}}
\newcommand{\package}[1]{\textsf{#1}}
\renewcommand{\commentbegin}{\ensuremath{\quad\Lbag\ }}
\renewcommand{\commentend}{\ensuremath{\Rbag}}

%\pgfprofilenewforenvironment{hscode}

% Tables should have the caption above
\floatstyle{plaintop}
\restylefloat{table}

\begin{document}

%\special{papersize=8.5in,11in}
\setlength{\pdfpageheight}{\paperheight}
\setlength{\pdfpagewidth}{\paperwidth}

\title{Abstracting Denotational Interpreters}
\subtitle{A Pattern for Sound, Compositional and Higher-order Static Program Analysis}

\author{Sebastian Graf}
\affiliation{%
  \institution{Karlsruhe Institute of Technology}
  \city{Karlsruhe}
  \country{Germany}
}
\email{sgraf1337@@gmail.com}

\author{Simon Peyton Jones}
\affiliation{%
  \institution{Epic Games}
  \city{Cambridge}
  \country{UK}
}
\email{simon.peytonjones@@gmail.com}

\ifmain

\begin{abstract}
  %We present a class of denotational semantics for lambda calculus that
  %generates coinductive traces of a corresponding small-step operational
  %semantics.
  %The appeal of our method is that the generated traces can be elaborated with
  %as much operational detail as needed, and that the structural definition
  %enables favorable induction principles.
  %Use of Guarded Domain Theory enables mutable state and thus the first
  %denotational semantics for call-by-need lambda calculus.
  %We demonstrate the usefulness of our trace semantics by proving correct a
  %static analysis for estimating the number of variable lookups by abstract
  %interpretation.
\end{abstract}

%% 2012 ACM Computing Classification System (CSS) concepts
%% Generate at 'http://dl.acm.org/ccs/ccs.cfm'.
\begin{CCSXML}
 <ccs2012>
   <concept>
       <concept_id>10011007.10011006.10011041</concept_id>
       <concept_desc>Software and its engineering~Compilers</concept_desc>
       <concept_significance>500</concept_significance>
       </concept>
   <concept>
       <concept_id>10011007.10011006.10011073</concept_id>
       <concept_desc>Software and its engineering~Software maintenance tools</concept_desc>
       <concept_significance>300</concept_significance>
       </concept>
   <concept>
       <concept_id>10011007.10011006.10011008.10011024.10011035</concept_id>
       <concept_desc>Software and its engineering~Procedures, functions and subroutines</concept_desc>
       <concept_significance>100</concept_significance>
       </concept>
   <concept>
       <concept_id>10011007.10011006.10011008.10011024.10011032</concept_id>
       <concept_desc>Software and its engineering~Constraints</concept_desc>
       <concept_significance>300</concept_significance>
       </concept>
   <concept>
       <concept_id>10011007.10011006.10011008.10011009.10011012</concept_id>
       <concept_desc>Software and its engineering~Functional languages</concept_desc>
       <concept_significance>300</concept_significance>
       </concept>
   <concept>
       <concept_id>10011007.10011006.10011008.10011009.10011021</concept_id>
       <concept_desc>Software and its engineering~Multiparadigm languages</concept_desc>
       <concept_significance>300</concept_significance>
       </concept>
 </ccs2012>
\end{CCSXML}

\ccsdesc[500]{Software and its engineering~Compilers}
\ccsdesc[300]{Software and its engineering~Software maintenance tools}
\ccsdesc[100]{Software and its engineering~Procedures, functions and subroutines}
\ccsdesc[300]{Software and its engineering~Constraints}
\ccsdesc[300]{Software and its engineering~Functional languages}
\ccsdesc[300]{Software and its engineering~Multiparadigm languages}
%% End of generated code

%% Keywords
%% comma separated list
\keywords{Programming language semantics, Abstract Interpretation, Static Program Analysis}  %% \keywords are mandatory in final camera-ready submission

\maketitle

%include Introduction.lhs
%include Absence.lhs
%include OpSem.lhs
%include Interpreter.lhs
%include Abstractions.lhs
%include Adequacy.lhs
%include Soundness.lhs
%include RelatedWork.lhs

%\begin{acks}
%We would like to thank the anonymous POPL reviewers for their feedback.
%, as well as Joachim Breitner, Bohdan Liesnikov, Anthony Travers and Sebastian Ullrich.
%\end{acks}

\clearpage
\bibliography{references}

\fi % \ifmain

\end{document}
