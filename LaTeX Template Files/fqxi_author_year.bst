%% fqxi_author_year.bst
%%
%% BibTeX bibliography style: Chicago Manual of Style (17th ed.)
%% Citation format: Author-Year (author-date)
%% Author name format: Surname, F. (e.g., "Rutherford, N.")
%%
%% In-text citations use \citep / \citet (natbib) or plain \cite{key}.
%% The label printed in the bibliography is (Surname Year).
%%
%% --------------------------------------------------------------------
%% This bibliography style is a derived work under the terms of the 
%% LaTeX Project Public License (LPPL) version 1.3c or later.
%%
%% This work is a hybrid style developed for the FQxI Foundational 
%% Review Series. It incorporates the following modified functions:
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
%% The underlying logic and formatting functions were debugged and optimized for improved effeciency with the technical assistance of Google Gemini 3 AI and Claude Sonnet 4.6 AI.
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
  { label}

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

%% Author-year label helpers
STRINGS { ay.label }

FUNCTION {make.ay.label}
{ author empty$
    { editor empty$
        { key empty$
            { cite$ }
            { key }
          if$
        }
        { editor #1 "{vv }{ll}" format.name$
          "t" change.case$
        }
      if$
    }
    { author #1 "{vv }{ll}" format.name$
      "t" change.case$
    }
  if$
  year empty$
    { "" * }
    { "(" * year * ")" * }
  if$
  'ay.label :=
}

FUNCTION {output.bibitem}
{ newline$
  make.ay.label
  "\bibitem[" write$
  ay.label write$
  "]{" write$
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

%% ---------------------------------------------------------------
%% Name formatting
%%
%% First author:  Surname, F.
%% Subsequent:    F. Surname
%% ---------------------------------------------------------------

INTEGERS { nameptr namesleft numnames }

%% format.names.chicago builds the full author string.
%% nameptr=1  → "{ll}{, f.}"   → "Rutherford, N."
%% nameptr>1  → "{f. }{ll}"    → "N. Rutherford"

FUNCTION {format.names.chicago}
{ 's :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { nameptr #1 =
        { s nameptr "{ll}{, f.}" format.name$ 't := }
        { s nameptr "{f.~}{ll}" format.name$ 't := }
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

% FUNCTION {format.names.chicago}
% { 's :=
%   #1 'nameptr :=
%   s num.names$ 'numnames :=
%   numnames 'namesleft :=
%     { namesleft #0 > }
%     { nameptr #1 =
%         { s nameptr "{ll}{, f.}" format.name$ 't := }
%         { s nameptr "{f.~}{ll}" format.name$ 't := }
%       if$
%       nameptr #1 >
%         { namesleft #1 >
%             { ", " * t * }
%             { numnames #2 >
%                 { "," * }
%                 'skip$
%               if$
%               t "others" =
%                 { " et~al." * }
%                 { " and " * t * }
%               if$
%             }
%           if$
%         }
%         't
%       if$
%       nameptr #1 + 'nameptr :=
%       namesleft #1 - 'namesleft :=
%     }
%   while$
% }

%% Editors: all in "F. Surname" order (never inverted)

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

% FUNCTION {format.names.editors}
% { 's :=
%   #1 'nameptr :=
%   s num.names$ 'numnames :=
%   numnames 'namesleft :=
%     { namesleft #0 > }
%     { s nameptr "{f.~}{ll}" format.name$ 't :=
%       nameptr #1 >
%         { namesleft #1 >
%             { ", " * t * }
%             { numnames #2 >
%                 { "," * }
%                 'skip$
%               if$
%               t "others" =
%                 { " et~al." * }
%                 { " and " * t * }
%               if$
%             }
%           if$
%         }
%         't
%       if$
%       nameptr #1 + 'nameptr :=
%       namesleft #1 - 'namesleft :=
%     }
%   while$
% }

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

%% format.date: used only for booklet/misc fallbacks (plain year)
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

%% format.year: outputs year as a standalone sentence block after authors
FUNCTION {format.year}
{ year empty$
    { "there's no year in " cite$ * warning$ "" }
    { year }
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

%% Chicago author-year journal: Vol., no. Num: Pages  (year already output after author)
FUNCTION {format.journal.vol.num.year.pages}
{ volume field.or.null
  number empty$
    'skip$
    { "~(" * number * ")" * }
  if$
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


%The "Archive" Check: It checks if an archive field exists (like hep-th or quant-ph). No Archive: It builds a link using just the eprint ID: \href{https://arxiv.org/abs/2101.12345}{{\ttfamily 2101.12345}}. With Archive: It combines them: \href{https://arxiv.org/abs/hep-th/9901001}{{\ttfamily hep-th/9901001}}.
%_____________________________________________________________


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

% This function is a priority-based selector for digital identifiers. It follows a specific logic: if the most preferred ID is missing, it checks for the second-best, and so on. Here, the preferred PID is the doi, then the arXiv eprint number, then the url, and if none of these three, it will return an empty string.  This is used in the aasjournalv7.bst file
%____________________________________________________________________________________________


INTEGERS { multiresult }

FUNCTION {multi.page.check}
{ 't :=
  #0 'multiresult :=
    { multiresult not
      t empty$ not
      and
    }
    { t #1 #1 substring$
      duplicate$ "-" =
      swap$ duplicate$ "," =
      swap$ "+" =
      or or
        { #1 'multiresult := }
        { t #2 global.max$ substring$ 't := }
      if$
    }
  while$
  multiresult
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
%% Sorting infrastructure (by author/editor, then year, then title)
%% ---------------------------------------------------------------

FUNCTION {sortify}
{ purify$
  "l" change.case$
}

INTEGERS { len }

FUNCTION {chop.word}
{ 's :=
  'len :=
  s #1 len substring$ =
    { s len #1 + global.max$ substring$ }
    's
  if$
}

FUNCTION {sort.format.names}
{ 's :=
  #1 'nameptr :=
  ""
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { nameptr #1 >
        { "   " * }
        'skip$
      if$
      s nameptr "{vv{ } }{ll{ }}{  ff{ }}{  jj{ }}" format.name$ 't :=
      nameptr numnames = t "others" = and
        { "et al" * }
        { t sortify * }
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}

FUNCTION {sort.format.title}
{ 't :=
  "A " #2
    "An " #3
      "The " #4 t chop.word
    chop.word
  chop.word
  sortify
  #1 global.max$ substring$
}

FUNCTION {author.sort}
{ author empty$
    { key empty$
        { "to sort, need author or key in " cite$ * warning$
          ""
        }
        { key sortify }
      if$
    }
    { author sort.format.names }
  if$
}

FUNCTION {author.editor.sort}
{ author empty$
    { editor empty$
        { key empty$
            { "to sort, need author, editor, or key in " cite$ * warning$
              ""
            }
            { key sortify }
          if$
        }
        { editor sort.format.names }
      if$
    }
    { author sort.format.names }
  if$
}

FUNCTION {author.organization.sort}
{ author empty$
    { organization empty$
        { key empty$
            { "to sort, need author, organization, or key in " cite$ * warning$
              ""
            }
            { key sortify }
          if$
        }
        { "The " #4 organization chop.word sortify }
      if$
    }
    { author sort.format.names }
  if$
}

FUNCTION {editor.organization.sort}
{ editor empty$
    { organization empty$
        { key empty$
            { "to sort, need editor, organization, or key in " cite$ * warning$
              ""
            }
            { key sortify }
          if$
        }
        { "The " #4 organization chop.word sortify }
      if$
    }
    { editor sort.format.names }
  if$
}

FUNCTION {presort}
{ type$ "book" =
  type$ "inbook" =
  or
    'author.editor.sort
    { type$ "proceedings" =
        'editor.organization.sort
        { type$ "manual" =
            'author.organization.sort
            'author.sort
          if$
        }
      if$
    }
  if$
  "    "
  *
  year field.or.null sortify
  *
  "    "
  *
  title field.or.null
  sort.format.title
  *
  #1 entry.max$ substring$
  'sort.key$ :=
}


FUNCTION {add.blank}
{  " " * before.all 'output.state :=
}



%% ---------------------------------------------------------------
%% Entry type definitions
%% ---------------------------------------------------------------

%% ARTICLE
%% Surname, F. Year. "Title." Journal Vol., no. Num: Pages.
FUNCTION {article}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.year "year" output.check
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
%% Surname, F. Year. Title. Edition. Place: Publisher.
FUNCTION {book}
{ output.bibitem
  author empty$
    { format.editors "author and editor" output.check }
    { format.authors output.nonnull
      crossref missing$
        { "author and editor" editor either.or.check }
        'skip$
      if$
    }
  if$
  new.block
  format.year "year" output.check
  new.block
  format.btitle "title" output.check
  format.edition output
  new.sentence
  address output
  publisher "publisher" output.check
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
  format.year output
  new.block
  format.title "title" output.check
  howpublished address new.block.checkb
  howpublished output
  address output
  new.block
  note output
  fin.entry
}

%% INBOOK
%% Surname, F. Year. "Chapter." In Title, Pages. Place: Publisher.
FUNCTION {inbook}
{ output.bibitem
  author empty$
    { format.editors "author and editor" output.check }
    { format.authors output.nonnull
      crossref missing$
        { "author and editor" editor either.or.check }
        'skip$
      if$
    }
  if$
  new.block
  format.year "year" output.check
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
  new.block
  format.pid output
  new.block
  note output
  fin.entry
}

%% INCOLLECTION
%% Surname, F. Year. "Title." In BookTitle, edited by F. Ed, Pages. Place: Publisher.
FUNCTION {incollection}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.year "year" output.check
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
  format.edition output
  new.block
  format.pid output
  new.block
  note output
  fin.entry
}

%% INPROCEEDINGS / CONFERENCE
%% Surname, F. Year. "Title." In ProcTitle, Pages. Place: Publisher/Organization.
FUNCTION {inproceedings}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.year "year" output.check
  new.block
  format.title "title" output.check
  new.block
  "In " format.booktitle * output.nonnull
  format.pages output
  new.sentence
  address output
  organization output
  publisher output
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
  format.year output
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
  new.block
  note output
  fin.entry
}

%% MASTERSTHESIS
%% Surname, F. Year. "Title." Master's thesis, School.
FUNCTION {mastersthesis}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.year "year" output.check
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
  format.year output
  title howpublished new.block.checkb
  format.title output
  howpublished new.block.checka
  howpublished output
  new.block
  note output
  fin.entry
}

%% PHDTHESIS
%% Surname, F. Year. "Title." PhD diss., School.
FUNCTION {phdthesis}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.year "year" output.check
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
  format.year output
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
  new.block
  note output
  fin.entry
}

%% TECHREPORT
%% Surname, F. Year. Title. Report Type Number. Institution.
FUNCTION {techreport}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.year "year" output.check
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
  new.block
  format.pid output
  new.block
  note output
  fin.entry
}

%% UNPUBLISHED
%% Surname, F. Year. "Title." Unpublished manuscript.
FUNCTION {unpublished}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.year "year" output.check
  new.block
  format.title "title" output.check
  new.block
  note "note" output.check
  fin.entry
}

%% DATASET
%% Surname, F. Year. "Title." [Dataset]. Version. Publisher/Distributor.
%%   Place. Accessed Month Day, Year. URL.
%%
%% Supported fields: author, year, title, version (via type), publisher,
%%   address, institution, howpublished, url, urldate, note.
%%
%% Map fields:
%%   version     → use the 'type' field (e.g., type = {Version 2.1})
%%   distributor → use 'publisher' or 'institution'
%%   repository  → use 'howpublished' (e.g., howpublished = {Zenodo})
%%   access date → use 'urldate' (e.g., urldate = {January 15, 2024})
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
  format.year "year" output.check
  new.block
  format.btitle "title" output.check
  new.block
  version empty$
    'skip$
    { "Version~" version * output } % Replaced add.blank with "Version "
  if$
  new.sentence
  publisher empty$
    { institution output }
    { publisher output }
  if$
  address output
  new.block
  howpublished output
  new.block
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
%% Journal abbreviation macros (common)
%% ---------------------------------------------------------------



%% ---------------------------------------------------------------
%% Read and sort
%% ---------------------------------------------------------------

READ

ITERATE {presort}

SORT

%% ---------------------------------------------------------------
%% Label generation (author-year)
%% ---------------------------------------------------------------

STRINGS { longest.label }
INTEGERS { longest.label.width }

FUNCTION {initialize.longest.label}
{ "" 'longest.label :=
  #0 'longest.label.width :=
}

FUNCTION {longest.label.pass}
{ make.ay.label
  ay.label 'label :=
  label width$ longest.label.width >
    { label 'longest.label :=
      label width$ 'longest.label.width :=
    }
    'skip$
  if$
}

EXECUTE {initialize.longest.label}

ITERATE {longest.label.pass}

%% ---------------------------------------------------------------
%% Output the bibliography
%% ---------------------------------------------------------------

FUNCTION {begin.bib}
{ preamble$ empty$
    'skip$
    { preamble$ write$ newline$ }
  if$
  "\begin{thebibliography}{" longest.label * "}" * write$ newline$
}

EXECUTE {begin.bib}

EXECUTE {init.state.consts}

ITERATE {call.type$}

FUNCTION {end.bib}
{ newline$
  "\end{thebibliography}" write$ newline$
}

EXECUTE {end.bib}