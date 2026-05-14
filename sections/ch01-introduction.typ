= Introduction <chap:introduction>


== Background and Motivation


Effective university study is an active process of selecting, organising, retrieving, explaining, and testing knowledge. Students do not normally revise from a single clean source. They work across lecture slides, scanned pages, textbook extracts, laboratory sheets, course notes, handwritten or copied summaries, past questions, and fragments collected during teaching. The difficulty is not only that this material may be long or distributed across files. The deeper problem is that study requires repeated transformation of the same material into different learning forms: readable notes, searchable passages, explanations, flashcards, practice questions, essay plans, and revision audio.

This matters because successful study depends on more than passive rereading. Research in cognitive and educational psychology identifies practice testing and distributed practice as high-utility learning techniques, while techniques such as rereading and highlighting are generally weaker when used alone. @ref-42 The testing effect literature also shows that retrieval practice can improve long-term retention rather than merely measure existing knowledge. @ref-43 A study assistant for college students should therefore support workflows that help learners move from source material to active recall, explanation, and self-assessment. It should not be limited to producing summaries.

Students also face a practical access problem. Important course material is often locked in inconvenient formats. A scanned handout cannot be searched reliably. A long set of lecture notes cannot be inserted into a single prompt without losing control over context. A dense technical passage may be difficult to revise while travelling or away from a screen. A student preparing for an exam may need to ask, "What does my material say about this topic?", "Can this be turned into flashcards?", "Can I listen to this section?", or "Can I practise with questions based only on these notes?" These are not isolated tasks. They are connected stages in a study workflow.

Modern AI systems are relevant to this problem because language models, document recognition, semantic retrieval, and speech synthesis can each support part of the workflow. However, a general conversational interface alone is not enough. If the assistant is not grounded in the student's own material, it may generate plausible but irrelevant explanations. If scanned documents are not converted into text, the system cannot reason over them. If retrieval is not available, long collections of notes become difficult to query precisely. If output is only visual text, some forms of revision and accessibility are not supported. The project is motivated by the need to coordinate these capabilities around the actual practices of student learning.

== Problem Statement


The problem addressed in this report is the design of an AI-assisted study system that can support college students working with their own educational material. The system must address three connected barriers.

The first barrier is input readiness. Many useful resources are not immediately usable by a language-based assistant. Optical character recognition is necessary when content is present as page images rather than machine-readable text. OCR is therefore not an end in itself; it is the entry point that allows scanned or PDF-based material to participate in later study workflows.

The second barrier is source-grounded access. Students often need help with material that is too large or too fragmented for direct use in a single interaction. Retrieval-augmented generation is relevant here because it combines language generation with an external store of retrieved passages. Lewis et al. describe RAG as a way to combine parametric model knowledge with non-parametric memory for knowledge-intensive tasks, improving the ability to use specific retrieved evidence during generation. @ref-37 In a study context, this principle supports asking questions over prepared notes, locating relevant course passages, and generating outputs that remain connected to the student's own source material.

The third barrier is output form. Study does not have a single target representation. A student may need verbatim transcription when checking extracted content, a lecture-style explanation when learning a difficult topic, an ELI5 explanation when building intuition, flashcards for retrieval practice, a quiz for self-assessment, essay questions for exam preparation, or audio for listening-based revision. Text-to-speech is especially relevant because learning can involve both visual and auditory channels. Multimedia learning research recognises that modality and presentation form can affect cognitive load and learning under appropriate conditions. @ref-46

The central design problem is therefore not simply to connect a language model to a document. It is to provide a coordinated assistant that helps a student move through a complete study cycle: prepare the material, retrieve relevant content, transform it into an appropriate learning artefact, and support revision in more than one mode.

This project presents `study-assistant`, an agent-based study assistant designed for source-grounded academic revision. The primary user is a college student who already has course material and wants to turn it into useful study outputs. The system is intended to support the work that happens between receiving course content and sitting an examination: extracting text, cleaning it, storing it for retrieval, querying it, generating explanations, producing active-recall artefacts, and converting selected material into speech.

At a high level, the system coordinates three capabilities. OCR-based input handling makes scanned or PDF-based material available as text. Retrieval-augmented assistance enables the student to search and reuse prepared study material when asking questions or generating study artefacts. Text-to-speech output enables selected material to become audio for listening-based revision. The agent provides the user-facing study workflow: it maps the student's intention to an appropriate mode such as transcription, study notes, lecture explanation, simplified explanation, flashcards, mind map, quiz, essay practice, retrieval, or audio preparation.

The purpose of the system is not to replace learning, teaching, or assessment. Its purpose is to reduce the friction between raw course material and effective study activity. The assistant supports the student in preparing material for learning, but the student remains responsible for understanding, checking, and applying the content. This distinction is important in education: AI systems can provide useful support, but they must be framed as aids to learning rather than substitutes for academic engagement.

AI-assisted learning systems are relevant because they can offer flexible access to explanations, practice material, and feedback-like interactions. Work on intelligent tutoring systems has shown that computer-based tutoring can have positive effects in higher education settings, although pedagogy and learning design remain important. @ref-44 More recent discussion of large language models in education identifies opportunities for personalised learning support and content generation, while also emphasising risks such as reliability, overreliance, and responsible use. @ref-45

This project is positioned within that balanced view. It uses AI capabilities to support concrete study tasks, but it constrains the assistant around prepared educational material and explicit study modes. This is especially important for college students, because their learning goals are tied to particular lectures, textbooks, assignments, and examination expectations. A generic answer may be fluent but educationally unhelpful if it does not match the course material. Source-grounded retrieval and controlled output modes help align the assistant with the student's actual learning context.

The agent-based structure is also relevant. A study workflow is naturally multi-step: a student may extract a chapter from a scanned PDF, store it, ask for the key concept behind a topic, generate flashcards, and then produce spoken revision notes. Treating these activities as one coordinated system reduces the burden on the student to manually move material between unrelated tools. The agent acts as the organising layer that connects the learning intention to the appropriate capability.

== Aim and Objectives


The aim of this project is to design and evaluate an agent-based study assistant that supports realistic student revision workflows using OCR, retrieval-augmented assistance, and text-to-speech. The system is intended to make course material easier to access, search, transform, and review while keeping generated outputs grounded in prepared source content.

The objectives are:

- to define the study-assistance problem from the perspective of college students preparing and revising course material;
- to design an agent-based workflow that coordinates input preparation, retrieval, explanation, active-recall generation, and audio revision;
- to support multiple study artefacts, including transcription, study notes, lecture-style explanation, simplified explanation, flashcards, mind maps, quizzes, and essay practice;
- to maintain source-grounded behaviour so that generated outputs are based on the student's material rather than unsupported external content;
- to support both integrated agent use and direct use of individual capabilities where a student only needs one stage of the workflow; and
- to evaluate the system's reliability and practical suitability for study preparation.

== Scope


The project focuses on study preparation and revision for students working with digital or digitised educational material. It is concerned with practical learning workflows rather than broad institutional learning management. The intended setting is a student who has course material and needs assistance turning it into searchable, explainable, testable, or listenable forms.

The system does not attempt to model a complete pedagogy, grade student work, replace instructors, or guarantee subject mastery. It also does not claim that generated study artefacts are automatically correct without student review. Its scope is the design of a modular AI-assisted workflow that helps students prepare and use their own material more effectively.

== Contributions


The main contribution of the project is a cohesive design for an agent-based study assistant that connects document extraction, semantic retrieval, study-output generation, and speech-based revision. The contribution is both conceptual and practical: the system frames AI assistance around the actual sequence of tasks a student performs when preparing for learning and assessment.

The report contributes:

- a student-centered problem formulation for AI-assisted study workflows;
- a high-level architecture for coordinating OCR, retrieval-augmented assistance, and text-to-speech;
- a study interaction model covering source preparation, retrieval, explanation, active recall, and audio revision;
- an evaluation of the system's reliability and practical behaviour; and
- a discussion of the role and limits of agent-based assistance in academic study.

== Thesis Structure


The remaining chapters follow a standard software engineering thesis structure. Chapter #ref(<chap:background>) introduces OCR, retrieval-augmented generation, text-to-speech, agentic tool use, and related AI study systems. Chapter #ref(<chap:requirements>) defines the system requirements and acceptance criteria. Chapter #ref(<chap:architecture>) presents the architecture used to coordinate agent-level workflows with specialised processing tools. Chapter #ref(<chap:implementation>) documents the implemented components. Chapter #ref(<chap:testing>) evaluates tool contracts, reliability, OCR performance, model suitability, and end-to-end workflows. Chapter #ref(<chap:discussion>) discusses the findings, contributions, practical implications, and limitations. Chapter #ref(<chap:conclusion>) summarises the results and future work.
