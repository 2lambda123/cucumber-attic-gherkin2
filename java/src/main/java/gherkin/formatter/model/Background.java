package gherkin.formatter.model;

import gherkin.formatter.Formatter;

import java.util.Collections;
import java.util.List;

public class Background extends FeatureElement {
    private final String type = "background";

    public Background(List<Comment> comments, String keyword, String name, String description, int line) {
        super(comments, Collections.<Tag>emptyList(), keyword, name, description, line);
    }

    @Override
    public void replay(Formatter formatter) {
        formatter.background(this);
    }
}
