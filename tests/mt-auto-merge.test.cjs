const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { test } = require('node:test');

const workflow = readFileSync(
  `${__dirname}/../shared-overwrite-all-repositories/.github/workflows/mt-auto-merge.yml`,
  'utf8',
);
const script = workflow.split('          script: |\n')[1]
  .split('\n').map(line => line.replace(/^ {12}/, '')).join('\n');
const runWorkflow = new (Object.getPrototypeOf(async () => {}).constructor)(
  'github', 'context', 'core', script,
);

function check(conclusion = 'SUCCESS', status = 'COMPLETED') {
  return { __typename: 'CheckRun', name: 'CI', status, conclusion };
}

async function run({
  author = 'montransit', draft = false, checks = [check()],
  reviewDecision = 'APPROVED', mergeStateStatus = 'CLEAN',
  codeOwners = true, rules = [], pages, mergeResult = { merged: true, sha: 'merged' },
} = {}) {
  const merges = [];
  const warnings = [];
  const queries = [];
  const listPulls = () => {};
  const github = {
    rest: {
      pulls: {
        list: listPulls,
        merge: async args => {
          merges.push(args);
          return { data: mergeResult };
        },
      },
    },
    paginate: async method => method === listPulls
      ? [{ number: 42, draft, user: { login: author } }]
      : rules,
    graphql: async (_, variables) => {
      const page = pages ? pages[queries.length] : { checks };
      queries.push(variables);
      return {
        repository: {
          pullRequest: {
            state: 'OPEN', isDraft: draft, headRefOid: page.sha || 'head',
            reviewDecision, mergeStateStatus,
            baseRef: {
              name: 'master',
              branchProtectionRule: { requiresCodeOwnerReviews: codeOwners },
            },
            commits: {
              nodes: [{
                commit: {
                  statusCheckRollup: {
                    contexts: {
                      nodes: page.checks,
                      pageInfo: {
                        hasNextPage: Boolean(page.cursor), endCursor: page.cursor,
                      },
                    },
                  },
                },
              }],
            },
          },
        },
      };
    },
  };
  await runWorkflow(github, { repo: { owner: 'mtransitapps', repo: 'commons' } }, {
    info: () => {}, warning: message => warnings.push(message),
  });
  return { merges, warnings, queries };
}

test('only eligible, non-draft authors can be squash-merged at the checked SHA', async () => {
  for (const author of ['montransit', 'Copilot', 'copilot-swe-agent[bot]', 'dependabot[bot]']) {
    const { merges } = await run({ author });
    assert.deepEqual(merges, [{
      owner: 'mtransitapps', repo: 'commons', pull_number: 42,
      merge_method: 'squash', sha: 'head',
    }]);
  }
  for (const options of [{ author: 'someone-else' }, { draft: true }]) {
    const { merges, queries } = await run(options);
    assert.equal(merges.length, 0);
    assert.equal(queries.length, 0);
  }
});

test('approval, CODEOWNER enforcement and clean merge state are mandatory', async () => {
  for (const options of [
    { reviewDecision: null }, { reviewDecision: 'REVIEW_REQUIRED' },
    { reviewDecision: 'CHANGES_REQUESTED' }, { mergeStateStatus: 'BLOCKED' },
    { mergeStateStatus: 'UNKNOWN' }, { codeOwners: false },
  ]) {
    assert.equal((await run(options)).merges.length, 0);
  }
  assert.equal((await run({ codeOwners: false })).warnings.length, 1);
  const { merges } = await run({
    codeOwners: false,
    rules: [{ type: 'pull_request', parameters: { require_code_owner_review: true } }],
  });
  assert.equal(merges.length, 1);
});

test('all checks must pass, not only required checks', async () => {
  for (const checks of [
    [], [check(), check('FAILURE')], [check(), check(null, 'IN_PROGRESS')],
    [check('CANCELLED')], [check('TIMED_OUT')], [check('ACTION_REQUIRED')],
    [{ __typename: 'StatusContext', state: 'PENDING' }],
    [{ __typename: 'StatusContext', state: 'ERROR' }],
    [{ __typename: 'StatusContext', state: 'FAILURE' }],
  ]) {
    assert.equal((await run({ checks })).merges.length, 0);
  }
  assert.equal((await run({
    checks: [
      check(), check('SKIPPED'), check('NEUTRAL'),
      { __typename: 'StatusContext', state: 'SUCCESS' },
    ],
  })).merges.length, 1);
});

test('checks beyond the first page can block merging', async () => {
  const { merges, queries } = await run({
    pages: [
      { checks: Array.from({ length: 100 }, () => check()), cursor: 'next-page' },
      { checks: [check('FAILURE')] },
    ],
  });
  assert.equal(merges.length, 0);
  assert.deepEqual(queries.map(query => query.cursor), [null, 'next-page']);
});

test('head changes during pagination and unsuccessful merges surface errors', async () => {
  await assert.rejects(run({
    pages: [
      { checks: [check()], cursor: 'next-page', sha: 'old-head' },
      { checks: [check()], sha: 'new-head' },
    ],
  }), /changed while reading checks/);
  await assert.rejects(run({
    mergeResult: { merged: false, message: 'Merge rejected' },
  }), /Merge rejected/);
});
