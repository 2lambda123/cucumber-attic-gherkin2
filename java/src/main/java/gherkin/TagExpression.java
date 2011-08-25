package gherkin;

import java.util.*;

public class TagExpression {
    private final Map<String, Integer> limits = new HashMap<String, Integer>();
    private And and = new And();

    public TagExpression(List<String> tagExpressions) {
        for (String tagExpression : tagExpressions) {
            add(tagExpression.split("\\s*,\\s*"));
        }
    }

    public boolean eval(Collection<String> tags) {
        return and.isEmpty() || and.eval(tags);
    }

    public Map<String, Integer> limits() {
        return limits;
    }

    private void add(String[] tags) {
        Or or = new Or();
        for (String tag : tags) {
            boolean negation;
            tag = tag.trim();
            if (tag.startsWith("~")) {
                tag = tag.substring(1);
                negation = true;
            } else {
                negation = false;
            }
            String[] tagAndLimit = tag.split(":");
            if (tagAndLimit.length == 2) {
                tag = tagAndLimit[0];
                int limit = Integer.parseInt(tagAndLimit[1]);
                if (limits.containsKey(tag) && limits.get(tag) != limit) {
                    throw new BadTagLimitException(tag, limits.get(tag), limit);
                }
                limits.put(tag, limit);
            }

            if (negation) {
                or.add(new Not(new Tag(tag)));
            } else {
                or.add(new Tag(tag));
            }
        }
        and.add(or);
    }

    private interface Expression {
        boolean eval(Collection<String> tags);
    }

    private class Not implements Expression {
        private final Expression expression;

        public Not(Expression expression) {
            this.expression = expression;
        }

        public boolean eval(Collection<String> tags) {
            return !expression.eval(tags);
        }
    }

    private class And implements Expression {
        private List<Expression> expressions = new ArrayList<Expression>();

        public void add(Expression expression) {
            expressions.add(expression);
        }

        public boolean eval(Collection<String> tags) {
            boolean result = true;
            for (Expression expression : expressions) {
                result = expression.eval(tags);
                if (!result) break;
            }
            return result;
        }

        public boolean isEmpty() {
            return expressions.isEmpty();
        }
    }

    private class Or implements Expression {
        private List<Expression> expressions = new ArrayList<Expression>();

        public void add(Expression expression) {
            expressions.add(expression);
        }

        public boolean eval(Collection<String> tags) {
            boolean result = false;
            for (Expression expression : expressions) {
                result = expression.eval(tags);
                if (result) break;
            }
            return result;
        }
    }

    private class Tag implements Expression {
        private final String tagName;

        public Tag(String tagName) {
            if (!tagName.startsWith("@")) {
                throw new BadTagException(tagName);
            }
            this.tagName = tagName;
        }

        public boolean eval(Collection<String> tags) {
            for (String tag : tags) {
                if (tagName.equals(tag)) {
                    return true;
                }
            }
            return false;
        }
    }

    private class BadTagException extends RuntimeException {
        public BadTagException(String tagName) {
            super("Bad tag: \"" + tagName + "\"");
        }
    }

    private class BadTagLimitException extends RuntimeException {
        public BadTagLimitException(String tag, int limitA, int limitB) {
            super("Inconsistent tag limits for " + tag + ": " + limitA + " and " + limitB);
        }
    }
}
