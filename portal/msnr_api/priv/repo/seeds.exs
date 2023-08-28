# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MsnrApi.Repo.insert!(%MsnrApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias MsnrApi.Semesters.Semester
alias MsnrApi.Accounts.User
alias MsnrApi.ActivityTypes.ActivityType
alias MsnrApi.ActivityTypes.TypeCode
alias MsnrApi.Topics.Topic
alias MsnrApi.Groups.Group

%Semester{}
|> Semester.changeset(%{year: 2022, is_active: true})
|> MsnrApi.Repo.insert!()

%ActivityType{}
|> ActivityType.changeset(%{
  name: "Grupe",
  description: "Prijavljivanje grupe za seminarske radove",
  code: TypeCode.group(),
  has_signup: false,
  is_group: false,
  content: %{}
})
|> MsnrApi.Repo.insert!()

%ActivityType{}
|> ActivityType.changeset(%{
  name: "Tema rada",
  description: "Odabir teme seminarskog rada",
  code: TypeCode.topic(),
  has_signup: false,
  is_group: true,
  content: %{}
})
|> MsnrApi.Repo.insert!()


%ActivityType{}
|> ActivityType.changeset(%{
  name: "CV",
  description: "Predaja CV-a",
  code: TypeCode.cv(),
  has_signup: false,
  is_group: false,
  content: %{files: [%{name: "CV", extension: ".pdf"}]}
})
|> MsnrApi.Repo.insert!()

%ActivityType{}
|> ActivityType.changeset(%{
  name: "Prva vezija rada",
  description: "Predaja prve verzije seminarskog rada",
  code: TypeCode.v1(),
  has_signup: false,
  is_group: true,
  content: %{files: [%{name: "V1", extension: ".pdf"}]}
})
|> MsnrApi.Repo.insert!()


%ActivityType{}
|> ActivityType.changeset(%{
  name: "Recenzija",
  description: "Recenziranje seminarskog rada",
  code: TypeCode.review(),
  has_signup: true,
  is_group: false,
  content: %{
    files: [
      %{name: "Recenzija", extension: ".pdf"},
      %{name: "Recenzija", extension: ".tex"}
    ]}
})
|> MsnrApi.Repo.insert!()

%ActivityType{}
|> ActivityType.changeset(%{
  name: "Finalna vezija rada",
  description: "Predaja finalne verzije seminarskog rada",
  code: TypeCode.v_final(),
  has_signup: false,
  is_group: true,
  content: %{files: [%{name: "VFinal", extension: ".zip"}]}
})
|> MsnrApi.Repo.insert!()


%User{}
|> User.changeset_password(%{
  email: "test@professor",
  password: "test",
  first_name: "Test",
  last_name: "Profesor",
  role: :professor
})
|> MsnrApi.Repo.insert!()
