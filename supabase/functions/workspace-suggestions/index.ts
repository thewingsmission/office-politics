const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const sectionFields = {
  workplace: [
    ["industry", "Industry"],
    ["department", "Department"],
    ["location", "Location"],
    ["workCulture", "Work Culture"],
    ["currentConditions", "Current Situation"],
    ["otherInformation", "Other Information"],
  ],
  yourself: [
    ["role", "Role"],
    ["sex", "Sex"],
    ["ageRange", "Age"],
    ["tenure", "Tenure"],
    ["goals", "Goals"],
    ["otherInformation", "Other Information"],
  ],
  colleague: [
    ["pseudonym", "Pseudonym"],
    ["role", "Role"],
    ["sex", "Sex"],
    ["ageRange", "Age"],
    ["observedStyle", "Observed Style"],
    ["otherInformation", "Other Information"],
  ],
  relationship: [
    ["relationToUser", "How You Work Together"],
    ["majorEvents", "Major Events"],
    ["currentRelationship", "Current Dynamic"],
    ["relationshipScore", "Relationship Score"],
    ["otherInformation", "Other Information"],
  ],
  event: [
    ["eventTitle", "Event Title"],
    ["dateTime", "Date and Time"],
    ["involvedPeople", "Involved People"],
    ["detailedStory", "Detailed Story"],
    ["personalFeeling", "Personal Feeling"],
    ["politicalImpact", "Political Impact"],
    ["personalStress", "Personal Stress"],
    ["urgency", "Urgency"],
    ["evidenceConfidence", "Evidence Confidence"],
  ],
} as const;

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (request.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }
  if (!request.headers.get("Authorization")) {
    return jsonResponse({ error: "Authentication required" }, 401);
  }

  const apiKey = Deno.env.get("PERPLEXITY_API_KEY");
  if (!apiKey) {
    return jsonResponse({ error: "Consultant service is not configured" }, 503);
  }

  try {
    const body = await request.json();
    const prompt = typeof body.prompt === "string" ? body.prompt.trim() : "";
    const section = typeof body.section === "string" ? body.section : "";
    const fields = sectionFields[section as keyof typeof sectionFields];
    if (!fields) {
      return jsonResponse({ error: "Workspace section is invalid" }, 400);
    }
    if (prompt.length < 10 || prompt.length > 12000) {
      return jsonResponse({ error: "Prompt length is invalid" }, 400);
    }

    const response = await fetch(
      "https://api.perplexity.ai/chat/completions",
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${apiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: Deno.env.get("PERPLEXITY_MODEL") ?? "sonar",
          temperature: 0.2,
          messages: [
            {
              role: "system",
              content:
                `You organize user-provided workplace notes without inventing facts or making personality diagnoses.

The current section is "${section}". Return only valid JSON in this exact shape:
{"fields":[{"key":"fieldKey","title":"very short summary","description":"complete concise description"}]}

Return exactly these ${fields.length} fields in this order:
${fields.map(([key, label]) => `${key} (${label})`).join(", ")}

Rules:
- Use only information stated or directly implied by the user's text.
- For every field not supported by the text, return an empty title and empty description.
- Never write "Unknown", "Not provided", or placeholder text.
- Keep each title under 50 characters.
- Keep each description factual, concise, and under 500 characters.
- Industry, location, department, sex, age, tenure, pseudonym, and relationship score are direct factual values: put the value in title and leave description empty.
- For every Role field, put the concise role or position in title and put stated duties and responsibilities in a point-form description. Do not invent typical duties that the user did not provide.
- Accept an exact age such as "32" or an approximate value such as "25–34" or "in their forties".
- Never infer sex or age when the user did not provide it.
- Keep a person's role separate from their department. A role is the individual's job or position (for example, teller, analyst, or manager). A department is an organizational unit (for example, Finance, Human Resources, Operations, or Retail Banking).
- Never place a role or job title in the department field. If the user says "I work in a bank as a teller," return Banking as the industry and leave department empty because no department was provided.
- Do not force useful information into an unrelated field merely because this section has no matching field.
- In the workplace section, discard role and job-duty details because they belong in the separate "yourself" section. Do not put them in work culture or current situation.
- In the workplace section, use Other Information for workplace details the user considers important when they do not fit another field.
- In the colleague section, describe only the colleague. Do not place relationship details in otherInformation; those belong in the separate relationship section.
- In the relationship section, describe only the connection between the two people identified in the prompt, their shared events, and their current dynamic. The pair may be the user and a colleague or two colleagues.
- For relationshipScore, return exactly one of "Very Bad", "Bad", "Neutral", "Good", or "Very Good" when the user's description supports a rating. Otherwise leave it empty. Use Very Bad for actively harmful or hostile dynamics, Bad for tense or low-trust dynamics, Neutral for limited or balanced evidence, Good for cooperative and trusting dynamics, and Very Good for strongly supportive and highly trusted dynamics.
- In the event section, organize one event only. Date and time and involved people are direct values. Detailed Story and Personal Feeling require a short title and point-form description. Keep observed actions separate from the user's feelings and interpretations.
- Event metric fields politicalImpact, personalStress, urgency, and evidenceConfidence must contain an integer from 0 to 100 in title and an empty description. Political Impact measures likely effect on power, reputation, resources, or decisions. Personal Stress measures the user's reported emotional strain. Urgency measures how soon the event needs attention. Evidence Confidence measures how well the account is supported by messages, documents, witnesses, or direct observation. Leave a metric empty when the prompt does not support it.
- Work culture means shared norms such as communication, hierarchy, trust, competition, and decision-making—not an individual's duties.
- Whenever a field has an empty title, its description must also be empty.
- For every supported non-factual field, always provide both a short title and a point-form description. Do not return a description without its title.
- In the yourself section, duties and responsibilities belong in the Role description, desired outcomes belong in Goals, and relevant unmatched context—including authority or constraints—belongs in Other Information.
- Example: "I am a teller, serve customers, want to become a supervisor, cannot approve loans, and am new to senior meetings" supports Role ("Teller" with customer service in its description), Goals ("Become a supervisor"), and Other Information ("Cannot approve loans" and "New to senior meetings").
- For every other non-empty description, use concise point form with no paragraph text.
- Use "• " for first-level points and "  ◦ " for second-level supporting points.
- Use no more than two bullet levels. Include only useful levels; do not force sub-points.
- Do not extract or repeat an employer or organization name.
- A pseudonym is a supplied invented name; never infer a real identity.`,
            },
            { role: "user", content: prompt },
          ],
        }),
      },
    );

    if (!response.ok) {
      return jsonResponse({ error: "Consultant request failed" }, 502);
    }

    const result = await response.json();
    const content = result?.choices?.[0]?.message?.content;
    if (typeof content !== "string") {
      return jsonResponse({ error: "Consultant returned invalid data" }, 502);
    }

    const parsed = JSON.parse(
      content.replace(/^```(?:json)?\s*/i, "").replace(/\s*```$/, ""),
    );
    const returnedFields = Array.isArray(parsed?.fields) ? parsed.fields : [];
    const normalizedFields = fields.map(([key]) => {
      const match = returnedFields.find((field: unknown) =>
        isRecord(field) && field.key === key
      );
      const title = isRecord(match) && typeof match.title === "string"
        ? match.title.trim().slice(0, 50)
        : "";
      return {
        key,
        title,
        description: isFactField(key) || title.length === 0
          ? ""
          : isRecord(match) && typeof match.description === "string"
          ? formatPointDescription(match.description)
          : "",
      };
    });
    return jsonResponse({ fields: normalizedFields }, 200);
  } catch {
    return jsonResponse({ error: "Unable to generate suggestions" }, 500);
  }
});

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function isFactField(key: string) {
  return [
    "industry",
    "location",
    "department",
    "role",
    "sex",
    "ageRange",
    "tenure",
    "pseudonym",
  ].includes(key);
}

function formatPointDescription(value: string) {
  return value
    .split(/\r?\n/)
    .map((line) => line.trimEnd())
    .filter((line) => line.trim().length > 0)
    .map((line) => {
      const trimmed = line.trim();
      if (line.startsWith("  ") || /^[-–—]{2}\s*/.test(trimmed)) {
        return `  ◦ ${trimmed.replace(/^(?:◦|[-–—]{1,2}|\*)\s*/, "")}`;
      }
      return `• ${trimmed.replace(/^(?:•|[-–—]|\*)\s*/, "")}`;
    })
    .join("\n")
    .slice(0, 500);
}

function jsonResponse(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
