from groq import Groq
from decouple import config
import json

client = Groq(
    api_key=config("GROQ_API_KEY")
)


def generate_ai_resume(username, github_data):

    prompt = f"""
    You are an expert technical recruiter,
    resume writer,
    portfolio strategist,
    and senior software engineer.

    Analyze this complete GitHub developer profile.

    Username:
    {username}

    GitHub Data:
    {github_data}

    Generate a COMPLETE developer analysis.

    Include:

    1. Professional About Me
    2. Resume Summary
    3. Developer Type
    4. Experience Level
    5. Technical Skills Categorized
    6. Top Strengths
    7. Weaknesses
    8. Recommended Technologies to Learn
    9. Suggested Career Roles
    10. ATS Resume Score
    11. Portfolio Bio
    12. LinkedIn Summary
    13. Detailed Project Descriptions
    14. Resume Bullet Points
    15. Best Project
    16. Coding Profile Analysis

    Return ONLY valid JSON.

    Structure:

    {{
      "about_me": "",
      "resume_summary": "",
      "developer_type": "",
      "experience_level": "",
      "skills": {{
        "frontend": [],
        "backend": [],
        "database": [],
        "tools": []
      }},
      "strengths": [],
      "weaknesses": [],
      "learn_next": [],
      "career_roles": [],
      "ats_score": "",
      "portfolio_bio": "",
      "linkedin_summary": "",
      "projects": [],
      "resume_points": [],
      "best_project": "",
      "coding_analysis": ""
    }}
    """

    completion = client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[
            {
                "role": "user",
                "content": prompt
            }
        ],
        temperature=0.7,
    )

    result = completion.choices[0].message.content

    result = result.replace("```json", "")
    result = result.replace("```", "")

    return json.loads(result)