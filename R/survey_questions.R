#' Retrieve a data frame containing question IDs and labels
#'
#' This function is soft deprecated; use \code{\link[qualtRics]{survey_questions}}
#' instead.
#' @param ... All arguments for \code{survey_questions}
#'
#' @export
getSurveyQuestions <- function(...) {
  warning("Soon, `getSurveyQuestions` will be deprecated. Try using `survey_questions()` instead.")
  survey_questions(...)
}


#' Retrieve a data frame containing question IDs and labels
#'
#' @param surveyID A string. Unique ID for the survey you want to download.
#' Returned as `id` by the \link[qualtRics]{all_surveys} function.
#'
#' @seealso See \url{https://api.qualtrics.com/docs} for documentation on the
#' Qualtrics API.
#' @export
#' @examples
#' \dontrun{
#' # Register your Qualtrics credentials if you haven't already
#' qualtrics_api_credentials(
#'   api_key = "<YOUR-API-KEY>",
#'   base_url = "<YOUR-BASE-URL>"
#' )
#'
#' # Retrieve a list of surveys
#' surveys <- all_surveys()
#'
#' # Retrieve questions for a survey
#' questions <- survey_questions(surveyID = surveys$id[6])
#'
#' # Retrieve a single survey, filtering for specific questions
#' mysurvey <- fetch_survey(
#'   surveyID = surveys$id[6],
#'   save_dir = tempdir(),
#'   include_questions = c("QID1", "QID2", "QID3"),
#'   verbose = TRUE
#' )
#' }
#'
survey_questions <- function(surveyID) {

  # Check params
  assert_base_url()
  assert_api_key()

  # Function-specific API stuff
  root_url <- append_root_url(Sys.getenv("QUALTRICS_BASE_URL"), "surveys")

  # Add survey id
  root_url <- paste0(
    root_url,
    "/",
    surveyID
  )

  # SEND REQUEST TO API ----

  # GET request to download metadata
  resp <- qualtrics_api_request("GET", root_url)

  # Get question information
  qi <- resp$result$questions

  # Questions, question labels, question names, and force response info
  quest <- tibble::tibble(
    qid = names(qi),
    qname = purrr::map_chr(qi, "questionName"),
    question = purrr::map_chr(qi, "questionText"),
    force_resp = purrr::map_lgl(qi, ~ .$validation$doesForceResponse))

  return(quest)
}
