CREATE TABLE survey (
  id SERIAL4 PRIMARY KEY,
  title TEXT NOT NULL,
  text TEXT NOT NULL,
  finished_title TEXT NOT NULL,
  finished_text TEXT NOT NULL,
  created TIMESTAMPTZ NOT NULL DEFAULT now(),
  open_from TIMESTAMPTZ NOT NULL,
  open_until TIMESTAMPTZ NOT NULL
);

CREATE TABLE survey_question (
  id SERIAL4 PRIMARY KEY,
  survey_id INT4 NOT NULL REFERENCES survey(id),
  position INT4 NOT NULL,
  question TEXT NOT NULL,
  description TEXT,
  answer_type TEXT NOT NULL,
  answer_options json
);

CREATE TABLE survey_answer_set (
  ident TEXT NOT NULL PRIMARY KEY,
  survey_id INT4 NOT NULL REFERENCES survey(id)
);

CREATE TABLE survey_answer (
  id SERIAL8 PRIMARY KEY,
  survey_answer_set_ident TEXT NOT NULL REFERENCES survey_answer_set(ident) ON DELETE CASCADE,
  survey_question_id INT4 NOT NULL REFERENCES survey_question(id),
  answer TEXT NOT NULL
);

CREATE TABLE survey_member (
  id SERIAL4 PRIMARY KEY,
  survey_id INT4 NOT NULL REFERENCES survey(id),
  member_id INT4 NOT NULL REFERENCES member(id),
  survey_answer_set_ident TEXT REFERENCES survey_answer_set(ident),
  started TIMESTAMPTZ DEFAULT now(),
  finished TIMESTAMPTZ,
  rejected TIMESTAMPTZ
);

INSERT INTO survey (id, title, text, finished_text, open_from, open_until) VALUES (
  1,
  'Example survey',
  'This is just an example',
  '<strong>Done!</strong><br>You finished it. Thank you very much.',
  '2021-10-06 12:00',
  '2021-10-14 12:00'
);

INSERT INTO survey_question (survey_id, position, question, answer_type, answer_options) VALUES
  (1, 1, 'What color do you like?', 'radio', '[ "Red", "Green", "Blue" ]'),
  (1, 2, 'What form do you like?', 'radio', '[ "Square", "Circle", "Hexagon" ]')
;

  
