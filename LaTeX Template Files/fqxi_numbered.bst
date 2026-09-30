%% fqxi_numbered.bst
%%
%% BibTeX bibliography style: Chicago Manual of Style (17th ed.)
%% Citation format: Citation-Sequence (Numbered / Vancouver style)
%% Author name format: Surname, F. (e.g., "Rutherford, N.")
%%
%% In-text citations use \cite{key} which generates [1], [2], etc.
%% The bibliography is printed in the order citations appear in the text.
%%
%%
%% --------------------------------------------------------------------
%% This bibliography style is a derived work under the terms of the 
%% LaTeX Project Public License (LPPL) version 1.3c or later.
%%
%% This work is a hybrid style developed for the FQxI Foundational 
%% Review Series. It has been specifically modified to follow a numbered 
%% Chicago Manual of Style (CMOS) citation-sequence system. 
%% 
%% It incorporates the following modified functions:
%%
%%   1. Author and title formatting from 'aasjournalv7.bst'
%%      (Functions: format.names.chicago, format.names.editors, 
%%      format.authors, format.editors, format.title, format.btitle, 
%%      format.booktitle)
%%      Copyright (c) 2021 American Astronomical Society.
%%
%%   2. Persistent Identifier (DOI/arXiv) logic adapted from 'JHEP.bst'
%%      and 'aasjournalv7.bst'
%%      (Functions: format.pid, format.eprint, format.doi, format.url)
%%      Copyright (c) SISSA Medialab.
%%
%% This script was refined, including the debugging and refactoring of 
%% core functions for improved performance, with the technical assistance 
%% of Google Gemini 3 AI and Claude Sonnet 4.6 AI.
%%
%% Modified by: Nathan Rutherford (nathan.rutherford@fqxi.org)
%% Date: 2026-04-23
%% --------------------------------------------------------------------

ENTRY
  { address
    author
    booktitle
    chapter
    doi
    archivePrefix
    eprint
    edition
    editor
    howpublished
    institution
    isbn
    journal
    key
    month
    note
    number
    organization
    pages
    publisher
    school
    series
    title
    type
    url
    urldate
    volume
    version
    year
  }
  {}
  { label }

INTEGERS { output.state before.all mid.sentence after.sentence after.block }

FUNCTION {init.state.consts}
{ #0 'before.all :=
  #1 'mid.sentence :=
  #2 'after.sentence :=
  #3 'after.block :=
}

STRINGS { s t }

%% ---------------------------------------------------------------
%% Output machinery
%% ---------------------------------------------------------------

FUNCTION {output.nonnull}
{ 's :=
  output.state mid.sentence =
    { ", " * write$ }
    { output.state after.block =
        { add.period$ write$
          newline$
          "\newblock " write$
        }
        { output.state before.all =
            'write$
            { add.period$ " " * write$ }
          if$
        }
      if$
      mid.sentence 'output.state :=
    }
  if$
  s
}

FUNCTION {output}
{ duplicate$ empty$
    'pop$
    'output.nonnull
  if$
}

FUNCTION {output.check}
{ 't :=
  duplicate$ empty$
    { pop$ "empty " t * " in " * cite$ * warning$ }
    'output.nonnull
  if$
}

%% Simple numeric bibitem generator
FUNCTION {output.bibitem}
{ newline$
  "\bibitem{" write$
  cite$ write$
  "}" write$
  newline$
  ""
  before.all 'output.state :=
}

FUNCTION {fin.entry}
{ add.period$
  write$
  newline$
}

FUNCTION {new.block}
{ output.state before.all =
    'skip$
    { after.block 'output.state := }
  if$
}

FUNCTION {new.sentence}
{ output.state after.block =
    'skip$
    { output.state before.all =
        'skip$
        { after.sentence 'output.state := }
      if$
    }
  if$
}

FUNCTION {not}
{   { #0 }
    { #1 }
  if$
}

FUNCTION {and}
{   'skip$
    { pop$ #0 }
  if$
}

FUNCTION {or}
{   { pop$ #1 }
    'skip$
  if$
}

FUNCTION {new.block.checka}
{ empty$
    'skip$
    'new.block
  if$
}

FUNCTION {new.block.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.block
  if$
}

FUNCTION {new.sentence.checka}
{ empty$
    'skip$
    'new.sentence
  if$
}

FUNCTION {new.sentence.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.sentence
  if$
}

FUNCTION {field.or.null}
{ duplicate$ empty$
    { pop$ "" }
    'skip$
  if$
}

FUNCTION {emphasize}
{ duplicate$ empty$
    { pop$ "" }
    { "\emph{" swap$ * "}" * }
  if$
}

FUNCTION {quote}
{ duplicate$ empty$
    { pop$ "" }
    { "``" swap$ * "''" * }
  if$
}

FUNCTION {format.isbn}
{ isbn empty$
    { "" }
    { "ISBN~" isbn * }
  if$
}

%% ---------------------------------------------------------------
%% Name formatting
%% ---------------------------------------------------------------

INTEGERS { nameptr namesleft numnames }

FUNCTION {format.names.chicago}
{ 's :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { nameptr #1 =
        { s nameptr "{vv~}{ll}{, f.}" format.name$ 't := }
        { s nameptr "{f.~}{vv~}{ll}" format.name$ 't := }
      if$
      numnames #6 > nameptr #4 = and
        { "others" 't := }
        'skip$
      if$

      nameptr #1 >
        { namesleft #1 >
            { t "others" =
                { ", et~al." *
                  #1 'namesleft := 
                }
                { ", " * t * }
              if$
            }
            { numnames #2 >
                { "," * }
                'skip$
              if$
              t "others" =
                { " et~al." * }
                { " and " * t * }
              if$
            }
          if$
        }
        't
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}

FUNCTION {format.names.editors}
{ 's :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { s nameptr "{f.~}{ll}" format.name$ 't :=
    
      numnames #6 > nameptr #4 = and
        { "others" 't := }
        'skip$
      if$
      nameptr #1 >
        { namesleft #1 >
            { t "others" =
                { ", et~al." *
                  #1 'namesleft :=
                }
                { ", " * t * }
              if$
            }
            { numnames #2 >
                { "," * }
                'skip$
              if$
              t "others" =
                { " et~al." * }
                { " and " * t * }
              if$
            }
          if$
        }
        't
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}

FUNCTION {format.authors}
{ author empty$
    { "" }
    { author format.names.chicago }
  if$
}

FUNCTION {format.editors}
{ editor empty$
    { "" }
    { editor format.names.editors
      editor num.names$ #1 >
        { ", eds." * }
        { ", ed." * }
      if$
    }
  if$
}

%% ---------------------------------------------------------------
%% Title formatting
%% ---------------------------------------------------------------

FUNCTION {format.title}
{ title empty$
    { "" }
    { title quote }
  if$
}

FUNCTION {format.btitle}
{ title emphasize }

FUNCTION {format.booktitle}
{ booktitle emphasize }

%% ---------------------------------------------------------------
%% Miscellaneous field formatters
%% ---------------------------------------------------------------

FUNCTION {n.dashify}
{ 't :=
  ""
    { t empty$ not }
    { t #1 #1 substring$ "-" =
        { t #1 #2 substring$ "--" = not
            { "--" *
              t #2 global.max$ substring$ 't :=
            }
            {   { t #1 #1 substring$ "-" = }
                { "-" *
                  t #2 global.max$ substring$ 't :=
                }
              while$
            }
          if$
        }
        { t #1 #1 substring$ *
          t #2 global.max$ substring$ 't :=
        }
      if$
    }
  while$
}

FUNCTION {format.date}
{ year empty$
    { month empty$
        { "" }
        { "there's a month but no year in " cite$ * warning$
          month
        }
      if$
    }
    { month empty$
        'year
        { month " " * year * }
      if$
    }
  if$
}

%% Moved year into parentheses for numbered journal style
FUNCTION {format.year.parens}
{ year empty$
    { "there's no year in " cite$ * warning$ "" }
    { " (" year * ")" * }
  if$
}

FUNCTION {format.edition}
{ edition empty$
    { "" }
    { output.state mid.sentence =
        { edition "l" change.case$ " ed." * }
        { edition "t" change.case$ " ed." * }
      if$
    }
  if$
}

FUNCTION {format.pages}
{ pages empty$
    { "" }
    { pages n.dashify }
  if$
}

%% Chicago numbered journal: Vol., no. Num (Year): Pages
FUNCTION {format.journal.vol.num.year.pages}
{ volume field.or.null
  number empty$
    'skip$
    { ", no.~" * number * }
  if$
  format.year.parens *
  pages empty$
    'skip$
    { ": " * pages n.dashify * }
  if$
}

FUNCTION {format.volume}
{ volume empty$
    { "" }
    { "vol.~" volume * }
  if$
}

FUNCTION {format.number.series}
{ volume empty$
    { number empty$
        { series field.or.null }
        { output.state mid.sentence =
            { "no.~" }
            { "No.~" }
          if$
          number *
          series empty$
            { "there's a number but no series in " cite$ * warning$ }
            { " in " * series * }
          if$
        }
      if$
    }
    { "" }
  if$
}

FUNCTION {format.doi}
{ doi empty$
    { "" }
    { "\href{https://doi.org/" doi * "}{doi:" * doi * "}" * }
  if$
}

FUNCTION {format.eprint}
{ eprint empty$
    { "" }
    { "\href{https://arxiv.org/abs/" eprint * "}{arXiv:" * eprint * "}" * }
  if$
}

FUNCTION {format.url}
{
  url empty$
  {""}
  {"\href{" url * "}{" * url * "}" *}
  if$
}

FUNCTION {format.pid}
{ doi empty$
{ eprint empty$ 
     { url empty$ 
       { "" }
       { format.url }
     if$}
     { format.eprint }
    if$}
  { format.doi }
  if$
}

FUNCTION {tie.or.space.connect}
{ duplicate$ text.length$ #3 <
    { "~" }
    { " " }
  if$
  swap$ * *
}

FUNCTION {either.or.check}
{ empty$
    'pop$
    { "can't use both " swap$ * " fields in " * cite$ * warning$ }
  if$
}

%% ---------------------------------------------------------------
%% Entry type definitions
%% ---------------------------------------------------------------

%% ARTICLE
%% Surname, F. "Title." Journal Vol., no. Num (Year): Pages.
FUNCTION {article}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  journal emphasize "journal" output.check
  format.journal.vol.num.year.pages output
  new.block
  format.pid output
  new.block
  note output
  fin.entry
}

%% BOOK
%% Surname, F. Title. Edition. Place: Publisher, Year.
FUNCTION {book}
{ output.bibitem
  author empty$
    { format.editors "author and editor" output.check }
    { format.authors output.nonnull
      crossref missing$
        { editor empty$
            'skip$
            { format.editors output }
          if$
        }
        'skip$
      if$
    }
  if$
  new.block
  format.btitle "title" output.check
  format.edition output
  new.sentence
  address output
  publisher "publisher" output.check
  format.date "year" output.check
  new.block
  format.isbn output
  new.block
  format.pid output
  new.block
  note output
  fin.entry
}

%% BOOKLET
FUNCTION {booklet}
{ output.bibitem
  format.authors output
  new.block
  format.title "title" output.check
  howpublished address new.block.checkb
  howpublished output
  address output
  format.date output
  new.block
  note output
  fin.entry
}

%% INBOOK
%% Surname, F. "Chapter." In Title, Pages. Place: Publisher, Year.
FUNCTION {inbook}
{ output.bibitem
  author empty$
    { format.editors "author and editor" output.check }
    { format.authors output.nonnull
      crossref missing$
        { editor empty$
            'skip$
            { format.editors output }
          if$
        }
        'skip$
      if$
    }
  if$
  new.block
  chapter empty$
    { format.btitle "title" output.check }
    { chapter quote output.nonnull }
  if$
  new.block
  "In " format.btitle * output.nonnull
  format.pages output
  new.sentence
  address output
  publisher "publisher" output.check
  format.date "year" output.check
  new.block
  format.pid output
  new.block
  note output
  fin.entry
}
%% INCOLLECTION
%% Surname, F. "Title." In BookTitle, edited by F. Ed, Pages. Place: Publisher, Year.
FUNCTION {incollection}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  editor empty$
    { "In " format.booktitle * output.nonnull }
    { "In " format.booktitle * ", edited by " * editor format.names.editors * output.nonnull }
  if$
  format.pages output
  new.sentence
  address output
  publisher "publisher" output.check
  format.date "year" output.check
  format.edition output
  new.block
  format.pid output
  new.block
  note output
  fin.entry
}

%% INPROCEEDINGS / CONFERENCE
%% Surname, F. "Title." In ProcTitle, Pages. Place: Publisher/Organization, Year.
FUNCTION {inproceedings}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  "In " format.booktitle * output.nonnull
  format.pages output
  new.sentence
  address output
  organization output
  publisher output
  format.date "year" output.check
  new.block
  format.pid output
  new.block
  note output
  fin.entry
}

FUNCTION {conference} { inproceedings }

%% MANUAL
FUNCTION {manual}
{ output.bibitem
  author empty$
    { organization empty$
        'skip$
        { organization output.nonnull
          address output
        }
      if$
    }
    { format.authors output.nonnull }
  if$
  new.block
  format.btitle "title" output.check
  author empty$
    { organization empty$
        { address new.block.checka
          address output
        }
        'skip$
      if$
    }
    { organization address new.block.checkb
      organization output
      address output
    }
  if$
  format.edition output
  format.date output
  new.block
  note output
  fin.entry
}

%% MASTERSTHESIS
%% Surname, F. "Title." Master's thesis, School, Year.
FUNCTION {mastersthesis}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  type empty$
    { "Master's thesis" }
    { type }
  if$
  output.nonnull
  school "school" output.check
  address output
  format.date "year" output.check
  new.block
  format.pid output
  new.block
  note output
  fin.entry
}

%% MISC
FUNCTION {misc}
{ output.bibitem
  format.authors output
  new.block
  title howpublished new.block.checkb
  format.title output
  howpublished new.block.checka
  howpublished output
  format.date output
  new.block
  note output
  fin.entry
}

%% PHDTHESIS
%% Surname, F. "Title." PhD diss., School, Year.
FUNCTION {phdthesis}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  type empty$
    { "PhD diss." }
    { type }
  if$
  output.nonnull
  school "school" output.check
  address output
  format.date "year" output.check
  new.block
  format.pid output
  new.block
  note output
  fin.entry
}

%% PROCEEDINGS
FUNCTION {proceedings}
{ output.bibitem
  editor empty$
    { organization output }
    { format.editors output.nonnull }
  if$
  new.block
  format.btitle "title" output.check
  format.volume output
  format.number.series output
  address empty$
    { editor empty$
        { publisher new.sentence.checka }
        { organization publisher new.sentence.checkb
          organization output
        }
      if$
      publisher output
    }
    { address output.nonnull
      new.sentence
      editor empty$
        'skip$
        { organization output }
      if$
      publisher output
    }
  if$
  format.date "year" output.check
  new.block
  note output
  fin.entry
}

%% TECHREPORT
%% Surname, F. Title. Report Type Number. Institution, Year.
FUNCTION {techreport}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.btitle "title" output.check
  new.block
  type empty$
    { "Technical Report" }
    { type }
  if$
  number empty$
    { "t" change.case$ }
    { number tie.or.space.connect }
  if$
  output.nonnull
  institution "institution" output.check
  address output
  format.date "year" output.check
  new.block
  format.pid output
  new.block
  note output
  fin.entry
}

%% UNPUBLISHED
%% Surname, F. "Title." Unpublished manuscript, Year.
FUNCTION {unpublished}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  note "note" output.check
  format.date output
  fin.entry
}

%% DATASET
FUNCTION {format.dataset.version}
{ type empty$
    { "" }
    { version }
  if$
}

FUNCTION {dataset}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.btitle "title" output.check
  new.block
  version empty$
    'skip$
    { "Version~" version * output }
  if$
  new.sentence
  publisher empty$
    { institution output }
    { publisher output }
  if$
  address output
  format.date "year" output.check
  new.block
  howpublished output
  new.block
  format.pid output
  new.block
  note output
  fin.entry
}

FUNCTION {default.type} { misc }

%% ---------------------------------------------------------------
%% Month macros
%% ---------------------------------------------------------------

MACRO {jan} {"January"}
MACRO {feb} {"February"}
MACRO {mar} {"March"}
MACRO {apr} {"April"}
MACRO {may} {"May"}
MACRO {jun} {"June"}
MACRO {jul} {"July"}
MACRO {aug} {"August"}
MACRO {sep} {"September"}
MACRO {oct} {"October"}
MACRO {nov} {"November"}
MACRO {dec} {"December"}

%% ---------------------------------------------------------------
%% Read execution (No SORT to maintain appearance order)
%% ---------------------------------------------------------------

READ

%% ---------------------------------------------------------------
%% Output the bibliography
%% ---------------------------------------------------------------

FUNCTION {begin.bib}
{ preamble$ empty$
    'skip$
    { preamble$ write$ newline$ }
  if$
  %% 99 is used as a standard width placeholder for numbered bibs
  "\begin{thebibliography}{99}" write$ newline$
}

EXECUTE {begin.bib}

EXECUTE {init.state.consts}

ITERATE {call.type$}

FUNCTION {end.bib}
{ newline$
  "\end{thebibliography}" write$ newline$
}

EXECUTE {end.bib}