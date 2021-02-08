module ControlledVocabularyUtilities

  # Provide presentational label for container type
  # Params:
  # +value+:: value of container type from API response
  def container_type_labels(value)
    labels = {
      'album' => 'Album',
      'artifactbox' => 'Artifact box',
      'audiocassette' => 'Audio cassette',
      'audiotape' => 'Audio tape',
      'box' => 'Box',
      'cardbox' => 'Card box',
      'carton' => 'Carton',
      'case' => 'Case',
      'cassette' => 'Cassette',
      'cassettebox' => 'Cassette box',
      'cdbox' => 'CD box',
      'diskette' => 'Diskette',
      'drawer' => 'Drawer',
      'drawingsbox' => 'Drawings box',
      'envelope' => 'Envelope',
      'flatbox' => 'Flat box',
      'flatfile' => 'Flat file',
      'flatfolder' => 'Flat folder',
      'folder' => 'Folder',
      'frame' => 'Frame',
      'halfbox' => 'Half box',
      'item' => 'Item',
      'largeenvelope' => 'Large envelope',
      'legalbox' => 'Legal box',
      'mapcase' => 'Map case',
      'mapfolder' => 'Map folder',
      'notecardbox' => 'Notecard box',
      'object' => 'Object',
      'othertype' => 'Other',
      'oversize' => 'Oversize',
      'oversizebox' => 'Oversize box',
      'oversizeflatbox' => 'Oversize flat box',
      'oversizelegalbox' => 'Oversize legal box',
      'page' => 'Page',
      'reel' => 'Reel',
      'reelbox' => 'Reel box',
      'scrapbook' => 'Scrapbook',
      'slidebox' => 'Slide box',
      'tube' => 'Tube',
      'tubebox' => 'Tube box',
      'videotape' => 'Video tape',
      'volume' => 'Volume'
    }
    labels[value] || value
  end


  # Provide MARC language codes that corresponds to language names
  def language_string_to_code
    {
      'English' => 'eng',
      'French' => 'fre',
      'Gaelic' => 'gla',
      'German' => 'ger',
      'Italian' => 'ita',
      'Spanish' => 'spa',
      'Latin' => 'lat',
      'Japanese' => 'jpn',
      'Russian' => 'rus',
      'Latvian' => 'lav',
      'Hebrew' => 'heb',
      'Yiddish' => 'yid',
      'Dutch' => 'dut',
      'Korean' => 'kor',
      'Arabic' => 'ara',
      'Swedish' => 'swe',
      'Turkish' => 'tur',
      'Czech' => 'cze',
      'Danish' => 'dan',
      'Chinese' => 'chi',
      'Maylay' => 'may',
      'Tagalog' => 'tgl',
      'Hungarian' => 'hun',
      'Icelandic' => 'ice',
      'Philippine languages (Malayo-Polynesian)' => 'phi',
      'Spanish-Nahuatl' => 'nah',
      'Bulgarian' => 'bul',
      'Romanian' => 'rum',
      'Interlingua' => 'ina',
      'Polish' => 'pol',
      'Greek' => 'gre',
      'Gujarati' => 'guj',
    #  "Volapük" => 'vol',
      'Estonian' => 'est',
      'Flemish' => 'dut',
      'Persian' => 'per',
      'Portuguese' => 'por',
      'Nipissing' => 'oji',
      'Crimean Tatar' => 'crh',
      'Pushto' => 'pus',
      'Tajik' => 'tgk',
      'Uzbek' => 'uzb',
      'Finnish' => 'fin',
      'Afrikaans' => 'afr',
      'Bantu' => 'bnt',
      'Geez' => 'gez',
      'Haitian Creole' => 'hat',
      'Lithuanian' => 'lit'
    }
  end


  # Controlled values for role subelement of name (source = MARC Relators)
  def marc_relators(code = nil)
    relators = {
      "acp"=>{:label=>"Art copyist", :uri=>"http://id.loc.gov/vocabulary/relators/acp"},
      "anl"=>{:label=>"Analyst", :uri=>"http://id.loc.gov/vocabulary/relators/anl"},
      "app"=>{:label=>"Applicant", :uri=>"http://id.loc.gov/vocabulary/relators/app"},
      "arr"=>{:label=>"Arranger", :uri=>"http://id.loc.gov/vocabulary/relators/arr"},
      "att"=>{:label=>"Attributed name", :uri=>"http://id.loc.gov/vocabulary/relators/att"},
      "aus"=>{:label=>"Author of screenplay, etc.", :uri=>"http://id.loc.gov/vocabulary/relators/aus"},
      "bkd"=>{:label=>"Book designer", :uri=>"http://id.loc.gov/vocabulary/relators/bkd"},
      "bpd"=>{:label=>"Bookplate designer", :uri=>"http://id.loc.gov/vocabulary/relators/bpd"},
      "clb"=>{:label=>"Collaborator", :uri=>"http://id.loc.gov/vocabulary/relators/clb"},
      "clt"=>{:label=>"Collotyper", :uri=>"http://id.loc.gov/vocabulary/relators/clt"},
      "cnd"=>{:label=>"Conductor", :uri=>"http://id.loc.gov/vocabulary/relators/cnd"},
      "col"=>{:label=>"Collector", :uri=>"http://id.loc.gov/vocabulary/relators/col"},
      "cos"=>{:label=>"Contestant", :uri=>"http://id.loc.gov/vocabulary/relators/cos"},
      "cpe"=>{:label=>"Complainant-appellee", :uri=>"http://id.loc.gov/vocabulary/relators/cpe"},
      "cre"=>{:label=>"Creator", :uri=>"http://id.loc.gov/vocabulary/relators/cre"},
      "csp"=>{:label=>"Consultant to a project", :uri=>"http://id.loc.gov/vocabulary/relators/csp"},
      "ctg"=>{:label=>"Cartographer", :uri=>"http://id.loc.gov/vocabulary/relators/ctg"},
      "cur"=>{:label=>"Curator of an exhibition", :uri=>"http://id.loc.gov/vocabulary/relators/cur"},
      "dfe"=>{:label=>"Defendant-appellee", :uri=>"http://id.loc.gov/vocabulary/relators/dfe"},
      "dln"=>{:label=>"Delineator", :uri=>"http://id.loc.gov/vocabulary/relators/dln"},
      "dpt"=>{:label=>"Depositor", :uri=>"http://id.loc.gov/vocabulary/relators/dpt"},
      "dst"=>{:label=>"Distributor", :uri=>"http://id.loc.gov/vocabulary/relators/dst"},
      "dto"=>{:label=>"Dedicator", :uri=>"http://id.loc.gov/vocabulary/relators/dto"},
      "elg"=>{:label=>"Electrician", :uri=>"http://id.loc.gov/vocabulary/relators/elg"},
      "evp"=>{:label=>"Event place", :uri=>"http://id.loc.gov/vocabulary/relators/evp"},
      "flm"=>{:label=>"Film editor", :uri=>"http://id.loc.gov/vocabulary/relators/flm"},
      "frg"=>{:label=>"Forger", :uri=>"http://id.loc.gov/vocabulary/relators/frg"},
      "ill"=>{:label=>"Illustrator", :uri=>"http://id.loc.gov/vocabulary/relators/ill"},
      "itr"=>{:label=>"Instrumentalist", :uri=>"http://id.loc.gov/vocabulary/relators/itr"},
      "lbt"=>{:label=>"Librettist", :uri=>"http://id.loc.gov/vocabulary/relators/lbt"},
      "lel"=>{:label=>"Libelee", :uri=>"http://id.loc.gov/vocabulary/relators/lel"},
      "lie"=>{:label=>"Libelant-appellee", :uri=>"http://id.loc.gov/vocabulary/relators/lie"},
      "lse"=>{:label=>"Licensee", :uri=>"http://id.loc.gov/vocabulary/relators/lse"},
      "mcp"=>{:label=>"Music copyist", :uri=>"http://id.loc.gov/vocabulary/relators/mcp"},
      "mon"=>{:label=>"Monitor", :uri=>"http://id.loc.gov/vocabulary/relators/mon"},
      "mte"=>{:label=>"Metal-engraver", :uri=>"http://id.loc.gov/vocabulary/relators/mte"},
      "org"=>{:label=>"Originator", :uri=>"http://id.loc.gov/vocabulary/relators/org"},
      "pat"=>{:label=>"Patron", :uri=>"http://id.loc.gov/vocabulary/relators/pat"},
      "pfr"=>{:label=>"Proofreader", :uri=>"http://id.loc.gov/vocabulary/relators/pfr"},
      "pmm"=>{:label=>"Production manager", :uri=>"http://id.loc.gov/vocabulary/relators/pmm"},
      "prc"=>{:label=>"Process contact", :uri=>"http://id.loc.gov/vocabulary/relators/prc"},
      "prm"=>{:label=>"Printmaker", :uri=>"http://id.loc.gov/vocabulary/relators/prm"},
      "pte"=>{:label=>"Plaintiff-appellee", :uri=>"http://id.loc.gov/vocabulary/relators/pte"},
      "pup"=>{:label=>"Publication place", :uri=>"http://id.loc.gov/vocabulary/relators/pup"},
      "red"=>{:label=>"Redactor", :uri=>"http://id.loc.gov/vocabulary/relators/red"},
      "rps"=>{:label=>"Repository", :uri=>"http://id.loc.gov/vocabulary/relators/rps"},
      "rsg"=>{:label=>"Restager", :uri=>"http://id.loc.gov/vocabulary/relators/rsg"},
      "rtm"=>{:label=>"Research team member", :uri=>"http://id.loc.gov/vocabulary/relators/rtm"},
      "scr"=>{:label=>"Scribe", :uri=>"http://id.loc.gov/vocabulary/relators/scr"},
      "sht"=>{:label=>"Supporting host", :uri=>"http://id.loc.gov/vocabulary/relators/sht"},
      "spy"=>{:label=>"Second party", :uri=>"http://id.loc.gov/vocabulary/relators/spy"},
      "stm"=>{:label=>"Stage manager", :uri=>"http://id.loc.gov/vocabulary/relators/stm"},
      "tch"=>{:label=>"Teacher", :uri=>"http://id.loc.gov/vocabulary/relators/tch"},
      "tyd"=>{:label=>"Type designer", :uri=>"http://id.loc.gov/vocabulary/relators/tyd"},
      "voc"=>{:label=>"Vocalist", :uri=>"http://id.loc.gov/vocabulary/relators/voc"},
      "wit"=>{:label=>"Witness", :uri=>"http://id.loc.gov/vocabulary/relators/wit"},
      "act"=>{:label=>"Actor", :uri=>"http://id.loc.gov/vocabulary/relators/act"},
      "anm"=>{:label=>"Animator", :uri=>"http://id.loc.gov/vocabulary/relators/anm"},
      "aqt"=>{:label=>"Author in quotations or text extracts", :uri=>"http://id.loc.gov/vocabulary/relators/aqt"},
      "art"=>{:label=>"Artist", :uri=>"http://id.loc.gov/vocabulary/relators/art"},
      "auc"=>{:label=>"Auctioneer", :uri=>"http://id.loc.gov/vocabulary/relators/auc"},
      "aut"=>{:label=>"Author", :uri=>"http://id.loc.gov/vocabulary/relators/aut"},
      "bkp"=>{:label=>"Book producer", :uri=>"http://id.loc.gov/vocabulary/relators/bkp"},
      "bsl"=>{:label=>"Bookseller", :uri=>"http://id.loc.gov/vocabulary/relators/bsl"},
      "cli"=>{:label=>"Client", :uri=>"http://id.loc.gov/vocabulary/relators/cli"},
      "cmm"=>{:label=>"Commentator", :uri=>"http://id.loc.gov/vocabulary/relators/cmm"},
      "cng"=>{:label=>"Cinematographer", :uri=>"http://id.loc.gov/vocabulary/relators/cng"},
      "cot"=>{:label=>"Contestant-appellant", :uri=>"http://id.loc.gov/vocabulary/relators/cot"},
      "cph"=>{:label=>"Copyright holder", :uri=>"http://id.loc.gov/vocabulary/relators/cph"},
      "crp"=>{:label=>"Correspondent", :uri=>"http://id.loc.gov/vocabulary/relators/crp"},
      "cst"=>{:label=>"Costume designer", :uri=>"http://id.loc.gov/vocabulary/relators/cst"},
      "ctr"=>{:label=>"Contractor", :uri=>"http://id.loc.gov/vocabulary/relators/ctr"},
      "cwt"=>{:label=>"Commentator for written text", :uri=>"http://id.loc.gov/vocabulary/relators/cwt"},
      "dft"=>{:label=>"Defendant-appellant", :uri=>"http://id.loc.gov/vocabulary/relators/dft"},
      "dnc"=>{:label=>"Dancer", :uri=>"http://id.loc.gov/vocabulary/relators/dnc"},
      "drm"=>{:label=>"Draftsman", :uri=>"http://id.loc.gov/vocabulary/relators/drm"},
      "dtc"=>{:label=>"Data contributor", :uri=>"http://id.loc.gov/vocabulary/relators/dtc"},
      "dub"=>{:label=>"Dubious author", :uri=>"http://id.loc.gov/vocabulary/relators/dub"},
      "elt"=>{:label=>"Electrotyper", :uri=>"http://id.loc.gov/vocabulary/relators/elt"},
      "exp"=>{:label=>"Expert", :uri=>"http://id.loc.gov/vocabulary/relators/exp"},
      "fmo"=>{:label=>"Former owner", :uri=>"http://id.loc.gov/vocabulary/relators/fmo"},
      "gis"=>{:label=>"Geographic information specialist", :uri=>"http://id.loc.gov/vocabulary/relators/gis"},
      "ilu"=>{:label=>"Illuminator", :uri=>"http://id.loc.gov/vocabulary/relators/ilu"},
      "ive"=>{:label=>"Interviewee", :uri=>"http://id.loc.gov/vocabulary/relators/ive"},
      "ldr"=>{:label=>"Laboratory director", :uri=>"http://id.loc.gov/vocabulary/relators/ldr"},
      "len"=>{:label=>"Lender", :uri=>"http://id.loc.gov/vocabulary/relators/len"},
      "lil"=>{:label=>"Libelant", :uri=>"http://id.loc.gov/vocabulary/relators/lil"},
      "lso"=>{:label=>"Licensor", :uri=>"http://id.loc.gov/vocabulary/relators/lso"},
      "mdc"=>{:label=>"Metadata contact", :uri=>"http://id.loc.gov/vocabulary/relators/mdc"},
      "mrb"=>{:label=>"Marbler", :uri=>"http://id.loc.gov/vocabulary/relators/mrb"},
      "mus"=>{:label=>"Musician", :uri=>"http://id.loc.gov/vocabulary/relators/mus"},
      "orm"=>{:label=>"Organizer of meeting", :uri=>"http://id.loc.gov/vocabulary/relators/orm"},
      "pbd"=>{:label=>"Publishing director", :uri=>"http://id.loc.gov/vocabulary/relators/pbd"},
      "pht"=>{:label=>"Photographer", :uri=>"http://id.loc.gov/vocabulary/relators/pht"},
      "pop"=>{:label=>"Printer of plates", :uri=>"http://id.loc.gov/vocabulary/relators/pop"},
      "prd"=>{:label=>"Production personnel", :uri=>"http://id.loc.gov/vocabulary/relators/prd"},
      "pro"=>{:label=>"Producer", :uri=>"http://id.loc.gov/vocabulary/relators/pro"},
      "ptf"=>{:label=>"Plaintiff", :uri=>"http://id.loc.gov/vocabulary/relators/ptf"},
      "rbr"=>{:label=>"Rubricator", :uri=>"http://id.loc.gov/vocabulary/relators/rbr"},
      "ren"=>{:label=>"Renderer", :uri=>"http://id.loc.gov/vocabulary/relators/ren"},
      "rpt"=>{:label=>"Reporter", :uri=>"http://id.loc.gov/vocabulary/relators/rpt"},
      "rsp"=>{:label=>"Respondent", :uri=>"http://id.loc.gov/vocabulary/relators/rsp"},
      "sad"=>{:label=>"Scientific advisor", :uri=>"http://id.loc.gov/vocabulary/relators/sad"},
      "sds"=>{:label=>"Sound designer", :uri=>"http://id.loc.gov/vocabulary/relators/sds"},
      "sng"=>{:label=>"Singer", :uri=>"http://id.loc.gov/vocabulary/relators/sng"},
      "srv"=>{:label=>"Surveyor", :uri=>"http://id.loc.gov/vocabulary/relators/srv"},
      "stn"=>{:label=>"Standards body", :uri=>"http://id.loc.gov/vocabulary/relators/stn"},
      "ths"=>{:label=>"Thesis advisor", :uri=>"http://id.loc.gov/vocabulary/relators/ths"},
      "tyg"=>{:label=>"Typographer", :uri=>"http://id.loc.gov/vocabulary/relators/tyg"},
      "wam"=>{:label=>"Writer of accompanying material", :uri=>"http://id.loc.gov/vocabulary/relators/wam"},
      "adp"=>{:label=>"Adapter", :uri=>"http://id.loc.gov/vocabulary/relators/adp"},
      "ann"=>{:label=>"Annotator", :uri=>"http://id.loc.gov/vocabulary/relators/ann"},
      "arc"=>{:label=>"Architect", :uri=>"http://id.loc.gov/vocabulary/relators/arc"},
      "asg"=>{:label=>"Assignee", :uri=>"http://id.loc.gov/vocabulary/relators/asg"},
      "aud"=>{:label=>"Author of dialog", :uri=>"http://id.loc.gov/vocabulary/relators/aud"},
      "bdd"=>{:label=>"Binding designer", :uri=>"http://id.loc.gov/vocabulary/relators/bdd"},
      "blw"=>{:label=>"Blurb writer", :uri=>"http://id.loc.gov/vocabulary/relators/blw"},
      "ccp"=>{:label=>"Conceptor", :uri=>"http://id.loc.gov/vocabulary/relators/ccp"},
      "cll"=>{:label=>"Calligrapher", :uri=>"http://id.loc.gov/vocabulary/relators/cll"},
      "cmp"=>{:label=>"Composer", :uri=>"http://id.loc.gov/vocabulary/relators/cmp"},
      "cns"=>{:label=>"Censor", :uri=>"http://id.loc.gov/vocabulary/relators/cns"},
      "com"=>{:label=>"Compiler", :uri=>"http://id.loc.gov/vocabulary/relators/com"},
      "cov"=>{:label=>"Cover designer", :uri=>"http://id.loc.gov/vocabulary/relators/cov"},
      "cpl"=>{:label=>"Complainant", :uri=>"http://id.loc.gov/vocabulary/relators/cpl"},
      "crr"=>{:label=>"Corrector", :uri=>"http://id.loc.gov/vocabulary/relators/crr"},
      "ctb"=>{:label=>"Contributor", :uri=>"http://id.loc.gov/vocabulary/relators/ctb"},
      "cts"=>{:label=>"Contestee", :uri=>"http://id.loc.gov/vocabulary/relators/cts"},
      "dbp"=>{:label=>"Distribution place", :uri=>"http://id.loc.gov/vocabulary/relators/dbp"},
      "dgg"=>{:label=>"Degree grantor", :uri=>"http://id.loc.gov/vocabulary/relators/dgg"},
      "dnr"=>{:label=>"Donor", :uri=>"http://id.loc.gov/vocabulary/relators/dnr"},
      "drt"=>{:label=>"Director", :uri=>"http://id.loc.gov/vocabulary/relators/drt"},
      "dte"=>{:label=>"Dedicatee", :uri=>"http://id.loc.gov/vocabulary/relators/dte"},
      "edt"=>{:label=>"Editor", :uri=>"http://id.loc.gov/vocabulary/relators/edt"},
      "eng"=>{:label=>"Engineer", :uri=>"http://id.loc.gov/vocabulary/relators/eng"},
      "fac"=>{:label=>"Facsimilist", :uri=>"http://id.loc.gov/vocabulary/relators/fac"},
      "fnd"=>{:label=>"Funder", :uri=>"http://id.loc.gov/vocabulary/relators/fnd"},
      "hnr"=>{:label=>"Honoree", :uri=>"http://id.loc.gov/vocabulary/relators/hnr"},
      "ins"=>{:label=>"Inscriber", :uri=>"http://id.loc.gov/vocabulary/relators/ins"},
      "ivr"=>{:label=>"Interviewer", :uri=>"http://id.loc.gov/vocabulary/relators/ivr"},
      "led"=>{:label=>"Lead", :uri=>"http://id.loc.gov/vocabulary/relators/led"},
      "let"=>{:label=>"Libelee-appellant", :uri=>"http://id.loc.gov/vocabulary/relators/let"},
      "lit"=>{:label=>"Libelant-appellant", :uri=>"http://id.loc.gov/vocabulary/relators/lit"},
      "ltg"=>{:label=>"Lithographer", :uri=>"http://id.loc.gov/vocabulary/relators/ltg"},
      "mfr"=>{:label=>"Manufacturer", :uri=>"http://id.loc.gov/vocabulary/relators/mfr"},
      "mrk"=>{:label=>"Markup editor", :uri=>"http://id.loc.gov/vocabulary/relators/mrk"},
      "nrt"=>{:label=>"Narrator", :uri=>"http://id.loc.gov/vocabulary/relators/nrt"},
      "oth"=>{:label=>"Other", :uri=>"http://id.loc.gov/vocabulary/relators/oth"},
      "pbl"=>{:label=>"Publisher", :uri=>"http://id.loc.gov/vocabulary/relators/pbl"},
      "plt"=>{:label=>"Platemaker", :uri=>"http://id.loc.gov/vocabulary/relators/plt"},
      "ppm"=>{:label=>"Papermaker", :uri=>"http://id.loc.gov/vocabulary/relators/ppm"},
      "prf"=>{:label=>"Performer", :uri=>"http://id.loc.gov/vocabulary/relators/prf"},
      "prt"=>{:label=>"Printer", :uri=>"http://id.loc.gov/vocabulary/relators/prt"},
      "pth"=>{:label=>"Patent holder", :uri=>"http://id.loc.gov/vocabulary/relators/pth"},
      "rce"=>{:label=>"Recording engineer", :uri=>"http://id.loc.gov/vocabulary/relators/rce"},
      "res"=>{:label=>"Researcher", :uri=>"http://id.loc.gov/vocabulary/relators/res"},
      "rpy"=>{:label=>"Responsible party", :uri=>"http://id.loc.gov/vocabulary/relators/rpy"},
      "rst"=>{:label=>"Respondent-appellant", :uri=>"http://id.loc.gov/vocabulary/relators/rst"},
      "sce"=>{:label=>"Scenarist", :uri=>"http://id.loc.gov/vocabulary/relators/sce"},
      "sec"=>{:label=>"Secretary", :uri=>"http://id.loc.gov/vocabulary/relators/sec"},
      "spk"=>{:label=>"Speaker", :uri=>"http://id.loc.gov/vocabulary/relators/spk"},
      "std"=>{:label=>"Set designer", :uri=>"http://id.loc.gov/vocabulary/relators/std"},
      "str"=>{:label=>"Stereotyper", :uri=>"http://id.loc.gov/vocabulary/relators/str"},
      "trc"=>{:label=>"Transcriber", :uri=>"http://id.loc.gov/vocabulary/relators/trc"},
      "uvp"=>{:label=>"University place", :uri=>"http://id.loc.gov/vocabulary/relators/uvp"},
      "wdc"=>{:label=>"Woodcutter", :uri=>"http://id.loc.gov/vocabulary/relators/wdc"},
      "aft"=>{:label=>"Author of afterword, colophon, etc.", :uri=>"http://id.loc.gov/vocabulary/relators/aft"},
      "ant"=>{:label=>"Bibliographic antecedent", :uri=>"http://id.loc.gov/vocabulary/relators/ant"},
      "ard"=>{:label=>"Artistic director", :uri=>"http://id.loc.gov/vocabulary/relators/ard"},
      "asn"=>{:label=>"Associated name", :uri=>"http://id.loc.gov/vocabulary/relators/asn"},
      "aui"=>{:label=>"Author of introduction, etc.", :uri=>"http://id.loc.gov/vocabulary/relators/aui"},
      "bjd"=>{:label=>"Bookjacket designer", :uri=>"http://id.loc.gov/vocabulary/relators/bjd"},
      "bnd"=>{:label=>"Binder", :uri=>"http://id.loc.gov/vocabulary/relators/bnd"},
      "chr"=>{:label=>"Choreographer", :uri=>"http://id.loc.gov/vocabulary/relators/chr"},
      "clr"=>{:label=>"Colorist", :uri=>"http://id.loc.gov/vocabulary/relators/clr"},
      "cmt"=>{:label=>"Compositor", :uri=>"http://id.loc.gov/vocabulary/relators/cmt"},
      "coe"=>{:label=>"Contestant-appellee", :uri=>"http://id.loc.gov/vocabulary/relators/coe"},
      "con"=>{:label=>"Conservator", :uri=>"http://id.loc.gov/vocabulary/relators/con"},
      "cpc"=>{:label=>"Copyright claimant", :uri=>"http://id.loc.gov/vocabulary/relators/cpc"},
      "cpt"=>{:label=>"Complainant-appellant", :uri=>"http://id.loc.gov/vocabulary/relators/cpt"},
      "csl"=>{:label=>"Consultant", :uri=>"http://id.loc.gov/vocabulary/relators/csl"},
      "cte"=>{:label=>"Contestee-appellee", :uri=>"http://id.loc.gov/vocabulary/relators/cte"},
      "ctt"=>{:label=>"Contestee-appellant", :uri=>"http://id.loc.gov/vocabulary/relators/ctt"},
      "dfd"=>{:label=>"Defendant", :uri=>"http://id.loc.gov/vocabulary/relators/dfd"},
      "dis"=>{:label=>"Dissertant", :uri=>"http://id.loc.gov/vocabulary/relators/dis"},
      "dpc"=>{:label=>"Depicted", :uri=>"http://id.loc.gov/vocabulary/relators/dpc"},
      "dsr"=>{:label=>"Designer", :uri=>"http://id.loc.gov/vocabulary/relators/dsr"},
      "dtm"=>{:label=>"Data manager", :uri=>"http://id.loc.gov/vocabulary/relators/dtm"},
      "egr"=>{:label=>"Engraver", :uri=>"http://id.loc.gov/vocabulary/relators/egr"},
      "etr"=>{:label=>"Etcher", :uri=>"http://id.loc.gov/vocabulary/relators/etr"},
      "fld"=>{:label=>"Field director", :uri=>"http://id.loc.gov/vocabulary/relators/fld"},
      "fpy"=>{:label=>"First party", :uri=>"http://id.loc.gov/vocabulary/relators/fpy"},
      "hst"=>{:label=>"Host", :uri=>"http://id.loc.gov/vocabulary/relators/hst"},
      "inv"=>{:label=>"Inventor", :uri=>"http://id.loc.gov/vocabulary/relators/inv"},
      "lbr"=>{:label=>"Laboratory", :uri=>"http://id.loc.gov/vocabulary/relators/lbr"},
      "lee"=>{:label=>"Libelee-appellee", :uri=>"http://id.loc.gov/vocabulary/relators/lee"},
      "lgd"=>{:label=>"Lighting designer", :uri=>"http://id.loc.gov/vocabulary/relators/lgd"},
      "lsa"=>{:label=>"Landscape architect", :uri=>"http://id.loc.gov/vocabulary/relators/lsa"},
      "lyr"=>{:label=>"Lyricist", :uri=>"http://id.loc.gov/vocabulary/relators/lyr"},
      "mod"=>{:label=>"Moderator", :uri=>"http://id.loc.gov/vocabulary/relators/mod"},
      "msd"=>{:label=>"Musical director", :uri=>"http://id.loc.gov/vocabulary/relators/msd"},
      "opn"=>{:label=>"Opponent", :uri=>"http://id.loc.gov/vocabulary/relators/opn"},
      "own"=>{:label=>"Owner", :uri=>"http://id.loc.gov/vocabulary/relators/own"},
      "pdr"=>{:label=>"Project director", :uri=>"http://id.loc.gov/vocabulary/relators/pdr"},
      "pma"=>{:label=>"Permitting agency", :uri=>"http://id.loc.gov/vocabulary/relators/pma"},
      "ppt"=>{:label=>"Puppeteer", :uri=>"http://id.loc.gov/vocabulary/relators/ppt"},
      "prg"=>{:label=>"Programmer", :uri=>"http://id.loc.gov/vocabulary/relators/prg"},
      "pta"=>{:label=>"Patent applicant", :uri=>"http://id.loc.gov/vocabulary/relators/pta"},
      "ptt"=>{:label=>"Plaintiff-appellant", :uri=>"http://id.loc.gov/vocabulary/relators/ptt"},
      "rcp"=>{:label=>"Recipient", :uri=>"http://id.loc.gov/vocabulary/relators/rcp"},
      "rev"=>{:label=>"Reviewer", :uri=>"http://id.loc.gov/vocabulary/relators/rev"},
      "rse"=>{:label=>"Respondent-appellee", :uri=>"http://id.loc.gov/vocabulary/relators/rse"},
      "rth"=>{:label=>"Research team head", :uri=>"http://id.loc.gov/vocabulary/relators/rth"},
      "scl"=>{:label=>"Sculptor", :uri=>"http://id.loc.gov/vocabulary/relators/scl"},
      "sgn"=>{:label=>"Signer", :uri=>"http://id.loc.gov/vocabulary/relators/sgn"},
      "spn"=>{:label=>"Sponsor", :uri=>"http://id.loc.gov/vocabulary/relators/spn"},
      "stl"=>{:label=>"Storyteller", :uri=>"http://id.loc.gov/vocabulary/relators/stl"},
      "tcd"=>{:label=>"Technical director", :uri=>"http://id.loc.gov/vocabulary/relators/tcd"},
      "trl"=>{:label=>"Translator", :uri=>"http://id.loc.gov/vocabulary/relators/trl"},
      "vdg"=>{:label=>"Videographer", :uri=>"http://id.loc.gov/vocabulary/relators/vdg"},
      "wde"=>{:label=>"Wood-engraver", :uri=>"http://id.loc.gov/vocabulary/relators/wde"}
    }
    if code
      relators[code]
    else
      relators
    end
  end


  def marc_relators_on_label(label = nil)
    relators_on_label = {}
    marc_relators.each do |k,v|
      relators_on_label[v[:label]] = { :code => k, :uri => v[:uri] }
    end
    if label
      relators_on_label[label]
    else
      relators_on_label
    end
  end


  def script_code_to_label
    {
      'Adlm' => 'Adlam',
      'Afak' => 'Afaka',
      'Aghb' => 'Caucasian Albanian',
      'Ahom' => 'Ahom, Tai Ahom',
      'Arab' => 'Arabic',
      'Aran' => 'Arabic (Nastaliq variant)',
      'Armi' => 'Imperial Aramaic',
      'Armn' => 'Armenian',
      'Avst' => 'Avestan',
      'Bali' => 'Balinese',
      'Bamu' => 'Bamum',
      'Bass' => 'Bassa Vah',
      'Batk' => 'Batak',
      'Beng' => 'Bengali (Bangla)',
      'Bhks' => 'Bhaiksuki',
      'Blis' => 'Blissymbols',
      'Bopo' => 'Bopomofo',
      'Brah' => 'Brahmi',
      'Brai' => 'Braille',
      'Bugi' => 'Buginese',
      'Buhd' => 'Buhid',
      'Cakm' => 'Chakma',
      'Cans' => 'Unified Canadian Aboriginal Syllabics',
      'Cari' => 'Carian',
      'Cham' => 'Cham',
      'Cher' => 'Cherokee',
      'Chrs' => 'Chorasmian',
      'Cirt' => 'Cirth',
      'Copt' => 'Coptic',
      'Cpmn' => 'Cypro-Minoan',
      'Cprt' => 'Cypriot syllabary',
      'Cyrl' => 'Cyrillic',
      'Cyrs' => 'Cyrillic (Old Church Slavonic variant)',
      'Deva' => 'Devanagari (Nagari)',
      'Diak' => 'Dives Akuru',
      'Dogr' => 'Dogra',
      'Dsrt' => 'Deseret (Mormon)',
      'Dupl' => 'Duployan shorthand, Duployan stenography',
      'Egyd' => 'Egyptian demotic',
      'Egyh' => 'Egyptian hieratic',
      'Egyp' => 'Egyptian hieroglyphs',
      'Elba' => 'Elbasan',
      'Elym' => 'Elymaic',
      'Ethi' => 'Ethiopic (Geʻez)',
      'Geok' => 'Khutsuri (Asomtavruli and Nuskhuri)',
      'Geor' => 'Georgian (Mkhedruli and Mtavruli)',
      'Glag' => 'Glagolitic',
      'Gong' => 'Gunjala Gondi',
      'Gonm' => 'Masaram Gondi',
      'Goth' => 'Gothic',
      'Gran' => 'Grantha',
      'Grek' => 'Greek',
      'Gujr' => 'Gujarati',
      'Guru' => 'Gurmukhi',
      'Hanb' => 'Han with Bopomofo (alias for Han + Bopomofo)',
      'Hang' => 'Hangul (Hangŭl, Hangeul)',
      'Hani' => 'Han (Hanzi, Kanji, Hanja)',
      'Hano' => 'Hanunoo (Hanunóo)',
      'Hans' => 'Han (Simplified variant)',
      'Hant' => 'Han (Traditional variant)',
      'Hatr' => 'Hatran',
      'Hebr' => 'Hebrew',
      'Hira' => 'Hiragana',
      'Hluw' => 'Anatolian Hieroglyphs (Luwian Hieroglyphs, Hittite Hieroglyphs)',
      'Hmng' => 'Pahawh Hmong',
      'Hmnp' => 'Nyiakeng Puachue Hmong',
      'Hrkt' => 'Japanese syllabaries (alias for Hiragana + Katakana)',
      'Hung' => 'Old Hungarian (Hungarian Runic)',
      'Inds' => 'Indus (Harappan)',
      'Ital' => 'Old Italic (Etruscan, Oscan, etc.)',
      'Jamo' => 'Jamo (alias for Jamo subset of Hangul)',
      'Java' => 'Javanese',
      'Jpan' => 'Japanese',
      'Jurc' => 'Jurchen',
      'Kali' => 'Kayah Li',
      'Kana' => 'Katakana',
      'Khar' => 'Kharoshthi',
      'Khmr' => 'Khmer',
      'Khoj' => 'Khojki',
      'Kitl' => 'Khitan large script',
      'Kits' => 'Khitan small script',
      'Knda' => 'Kannada',
      'Kore' => 'Korean (alias for Hangul + Han)',
      'Kpel' => 'Kpelle',
      'Kthi' => 'Kaithi',
      'Lana' => 'Tai Tham (Lanna)',
      'Laoo' => 'Lao',
      'Latf' => 'Latin (Fraktur variant)',
      'Latg' => 'Latin (Gaelic variant)',
      'Latn' => 'Latin',
      'Leke' => 'Leke',
      'Lepc' => 'Lepcha (Róng)',
      'Limb' => 'Limbu',
      'Lina' => 'Linear A',
      'Linb' => 'Linear B',
      'Lisu' => 'Lisu (Fraser)',
      'Loma' => 'Loma',
      'Lyci' => 'Lycian',
      'Lydi' => 'Lydian',
      'Mahj' => 'Mahajani',
      'Maka' => 'Makasar',
      'Mand' => 'Mandaic, Mandaean',
      'Mani' => 'Manichaean',
      'Marc' => 'Marchen',
      'Maya' => 'Mayan hieroglyphs',
      'Medf' => 'Medefaidrin (Oberi Okaime, Oberi Ɔkaimɛ)',
      'Mend' => 'Mende Kikakui',
      'Merc' => 'Meroitic Cursive',
      'Mero' => 'Meroitic Hieroglyphs',
      'Mlym' => 'Malayalam',
      'Modi' => 'Modi, Moḍī',
      'Mong' => 'Mongolian',
      'Moon' => 'Moon (Moon code, Moon script, Moon type)',
      'Mroo' => 'Mro, Mru',
      'Mtei' => 'Meitei Mayek (Meithei, Meetei)',
      'Mult' => 'Multani',
      'Mymr' => 'Myanmar (Burmese)',
      'Nand' => 'Nandinagari',
      'Narb' => 'Old North Arabian (Ancient North Arabian)',
      'Nbat' => 'Nabataean',
      'Newa' => 'Newa, Newar, Newari, Nepāla lipi',
      'Nkdb' => 'Naxi Dongba',
      'Nkgb' => 'Naxi Geba',
      'Nkoo' => 'N’Ko',
      'Nshu' => 'Nüshu',
      'Ogam' => 'Ogham',
      'Olck' => 'Ol Chiki',
      'Orkh' => 'Old Turkic, Orkhon Runic',
      'Orya' => 'Oriya',
      'Osge' => 'Osage',
      'Osma' => 'Osmanya',
      'Ougr' => 'Old Uyghur',
      'Palm' => 'Palmyrene',
      'Pauc' => 'Pau Cin Hau',
      'Pcun' => 'Proto-Cuneiform',
      'Pelm' => 'Proto-Elamite',
      'Perm' => 'Old Permic',
      'Phag' => 'Phags-pa',
      'Phli' => 'Inscriptional Pahlavi',
      'Phlp' => 'Psalter Pahlavi',
      'Phlv' => 'Book Pahlavi',
      'Phnx' => 'Phoenician',
      'Plrd' => 'Miao (Pollard)',
      'Piqd' => 'Klingon (KLI pIqaD)',
      'Prti' => 'Inscriptional Parthian',
      'Psin' => 'Proto-Sinaitic',
      'Ranj' => 'Ranjana',
      'Rjng' => 'Rejang (Redjang, Kaganga)',
      'Rohg' => 'Hanifi Rohingya',
      'Roro' => 'Rongorongo',
      'Runr' => 'Runic',
      'Samr' => 'Samaritan',
      'Sara' => 'Sarati',
      'Sarb' => 'Old South Arabian',
      'Saur' => 'Saurashtra',
      'Sgnw' => 'SignWriting',
      'Shaw' => 'Shavian (Shaw)',
      'Shrd' => 'Sharada, Śāradā',
      'Shui' => 'Shuishu',
      'Sidd' => 'Siddham, Siddhaṃ, Siddhamātṛkā',
      'Sind' => 'Khudawadi, Sindhi',
      'Sinh' => 'Sinhala',
      'Sogd' => 'Sogdian',
      'Sogo' => 'Old Sogdian',
      'Sora' => 'Sora Sompeng',
      'Soyo' => 'Soyombo',
      'Sund' => 'Sundanese',
      'Sylo' => 'Syloti Nagri',
      'Syrc' => 'Syriac',
      'Syre' => 'Syriac (Estrangelo variant)',
      'Syrj' => 'Syriac (Western variant)',
      'Syrn' => 'Syriac (Eastern variant)',
      'Tagb' => 'Tagbanwa',
      'Takr' => 'Takri, Ṭākrī, Ṭāṅkrī',
      'Tale' => 'Tai Le',
      'Talu' => 'New Tai Lue',
      'Taml' => 'Tamil',
      'Tang' => 'Tangut',
      'Tavt' => 'Tai Viet',
      'Telu' => 'Telugu',
      'Teng' => 'Tengwar',
      'Tfng' => 'Tifinagh (Berber)',
      'Tglg' => 'Tagalog (Baybayin, Alibata)',
      'Thaa' => 'Thaana',
      'Thai' => 'Thai',
      'Tibt' => 'Tibetan',
      'Tirh' => 'Tirhuta',
      'Toto' => 'Toto',
      'Ugar' => 'Ugaritic',
      'Vaii' => 'Vai',
      'Visp' => 'Visible Speech',
      'Wara' => 'Warang Citi (Varang Kshiti)',
      'Wcho' => 'Wancho',
      'Wole' => 'Woleai',
      'Xpeo' => 'Old Persian',
      'Xsux' => 'Cuneiform, Sumero-Akkadian',
      'Yezi' => 'Yezidi',
      'Yiii' => 'Yi',
      'Zanb' => 'Zanabazar Square (Zanabazarin Dörböljin Useg, Xewtee Dörböljin Bicig, Horizontal Square Script)',
      'Zinh' => 'Code for inherited script',
      'Zmth' => 'Mathematical notation',
      'Zsye' => 'Symbols (Emoji variant)',
      'Zsym' => 'Symbols',
      'Zyyy' => 'Unknown script'
    }
  end

end
