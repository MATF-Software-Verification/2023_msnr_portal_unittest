module StudentPage.AssignmentContent.Model exposing (..)

import StudentPage.AssignmentContent.FilesContent as FilesContent
import StudentPage.AssignmentContent.GroupContent as GroupContent
import StudentPage.AssignmentContent.SignupContent as SignupContent
import StudentPage.AssignmentContent.TopicContent as TopicContent


type Model
    = Files FilesContent.Model
    | Group GroupContent.Model
    | Topic TopicContent.Model
    | Signup SignupContent.Model
    | Empty
