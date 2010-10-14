package gherkin.formatter.model;

import gherkin.formatter.Argument;
import gherkin.formatter.Formatter;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Step extends BasicStatement {
    private Object multiline_arg;
    private Result result;

    public Step(List<Comment> comments, String keyword, String name, int line, Object multilineArg, Result result) {
        super(comments, keyword, name, line);
        this.multiline_arg = multilineArg;
        this.result = result;
    }

    @Override
    public Map<Object,Object> toMap() {
        Map<Object,Object> map = super.toMap();
        if (getRows() != null) {
            Map<Object,Object> multilineArg = new HashMap<Object,Object>();
            multilineArg.put("type", "table");
            multilineArg.put("value", map.get("multiline_arg"));
            map.put("multiline_arg", multilineArg);
        } else if (getPyString() != null) {
            ((Map<Object,Object>) map.get("multiline_arg")).put("type", "py_string");
        }
        return map;
    }

    @Override
    public Range getLineRange() {
        Range range = super.getLineRange();
        if (getRows() != null) {
            range = new Range(range.getFirst(), getRows().get(getRows().size() - 1).getLine());
        } else if (getPyString() != null) {
            range = new Range(range.getFirst(), getPyString().getLineRange().getLast());
        }
        return range;
    }

    @Override
    public void replay(Formatter formatter) {
        formatter.step(this);
    }

    public void setMultilineArg(Object multilineArg) {
        this.multiline_arg = multilineArg;
    }

    public Object getMultilineArg() {
        return multiline_arg;
    }

    public Result getResult() {
        return result;
    }

    public List<Row> getRows() {
        return multiline_arg instanceof List ? (List<Row>) multiline_arg : null;
    }

    public PyString getPyString() {
        return multiline_arg instanceof PyString ? (PyString) multiline_arg : null;
    }

    public List<Argument> getArguments() {
        return result != null ? result.getArguments() : Collections.<Argument>emptyList();
    }

    public String getStatus() {
        return result != null ? result.getStatus() : "undefined";
    }
}
