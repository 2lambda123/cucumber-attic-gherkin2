package gherkin.parser;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import gherkin.Listener;

public class FilterListener implements Listener {
	
	private final List filters;
	private final Listener listener;
	private final List<Sexp> metaBuffer = new ArrayList<Sexp>();
	private final List<Sexp> featureBuffer = new ArrayList<Sexp>();
	private final List<Sexp> scenarioBuffer = new ArrayList<Sexp>();
	private final List<Sexp> examplesBuffer = new ArrayList<Sexp>();
	private final List<Sexp> examplesRowsBuffer = new ArrayList<Sexp>();
	
	private List featureTags = new ArrayList();
	private List scenarioTags = new ArrayList();
	private List exampleTags = new ArrayList();
	
	private boolean featureOk = false;
	private TableState tableState = TableState.STEP;
	private boolean scenarioOk = false;
	private boolean examplesOk = false;
	private IFilterMethod filterMethod;

	@SuppressWarnings("unchecked")
	public FilterListener(Listener listener, List filters) {
		this.listener = listener;
		this.filters = filters;
		detectFilters(filters);
	}

	@Override
	public void tag(String name, int line) throws Exception {
		if (hasNoFilters()){
			listener.tag(name, line);
		}
		else{
			metaBuffer.add(new Sexp(Sexp.Events.TAG, name, line));
		}
		replayBuffersIfAllOk();
	}
	
	@Override
	public void comment(String content, int line) throws Exception {
		if (hasNoFilters()){
			listener.comment(content, line);
		}
		else{
			metaBuffer.add(new Sexp(Sexp.Events.COMMENT, content, line));
		}
		replayBuffersIfAllOk();
	}

	@Override
	public void feature(String keyword, String name, int line) throws Exception {
		System.out.println("Feature Line: " + line);
		if (hasNoFilters()){
			listener.feature(keyword, name, line);
		}
		else{
			Sexp sexp = new Sexp(Sexp.Events.FEATURE, keyword, name, line);
			featureBuffer.clear();
			featureBuffer.addAll(metaBuffer);
			featureBuffer.add(sexp);
			featureTags = extractTags();
			metaBuffer.clear();
			if (filterMatch(sexp)){
				featureOk = true;
			}
		}
		replayBuffersIfAllOk();
	}
	
	@Override
	public void background(String keyword, String name, int line)
			throws Exception {
		if (hasNoFilters()){
			listener.background(keyword, name, line);
		}
		else{
			Sexp sexp = new Sexp(Sexp.Events.BACKGROUND, keyword, name, line);
			featureBuffer.addAll(metaBuffer);
			featureBuffer.add(sexp);
			metaBuffer.clear();
			tableState = TableState.BACKGROUND;
			if (filterMatch(sexp)){
				featureOk = true;
			}
		}
		replayBuffersIfAllOk();
	}

	@Override
	public void scenario(String keyword, String name, int line)
			throws Exception {
		System.out.println("Scenario: " + keyword + ", " + name + "," + line);
		if (hasNoFilters()){
			listener.scenario(keyword, name, line);
		}
		else{
			Sexp sexp = new Sexp(Sexp.Events.SCENARIO, keyword, name, line);
			replayExamplesRowsBuffer();
			scenarioBuffer.clear();
			scenarioBuffer.addAll(metaBuffer);
			scenarioBuffer.add(sexp);
			scenarioTags = extractTags();
			exampleTags.clear();
			metaBuffer.clear();
			if (filterMatch(scenarioBuffer) || tagMatch()){
				scenarioOk = true;
			}
			examplesOk = false;
			tableState = TableState.STEP;
		}
		replayBuffersIfAllOk();
	}

	@Override
	public void scenario_outline(String keyword, String name, int line)
			throws Exception {
		if (hasNoFilters()){
			listener.scenario_outline(keyword, name, line);
		}
		else{
			Sexp sexp = new Sexp(Sexp.Events.SCENARIO_OUTLINE, keyword, name, line);
			replayExamplesRowsBuffer();
			scenarioBuffer.clear();
			scenarioBuffer.addAll(metaBuffer);
			scenarioBuffer.add(sexp);
			scenarioTags = extractTags();
			exampleTags.clear();
			metaBuffer.clear();
			if (filterMatch(scenarioBuffer)){
				scenarioOk = true;
			}
			examplesOk = false;
			tableState = TableState.STEP;
		}
		replayBuffersIfAllOk();
	}

	@Override
	public void examples(String keyword, String name, int line)
			throws Exception {
		if (hasNoFilters()){
			listener.examples(keyword, name, line);
		}
		else{
			Sexp sexp = new Sexp(Sexp.Events.EXAMPLES, keyword, name, line);
			replayExamplesRowsBuffer();
			examplesBuffer.clear();
			examplesBuffer.addAll(metaBuffer);
			examplesBuffer.add(sexp);
			exampleTags = extractTags();
			metaBuffer.clear();
			examplesRowsBuffer.clear();
			if (filterMatch(examplesBuffer) || tagMatch()){
				examplesOk = true;
			}
			tableState = TableState.EXAMPLES;
		}
		replayBuffersIfAllOk();
	}

	@Override
	public void step(String keyword, String name, int line) throws IOException,
			Exception {
		System.out.printf("Step %s, %s, %d\n", keyword, name, line);
		if (hasNoFilters()){
			listener.step(keyword, name, line);
		}
		else{
			Sexp sexp = new Sexp(Sexp.Events.STEP, keyword, name, line);
			if (tableState.equals(TableState.BACKGROUND)){
				featureBuffer.addAll(metaBuffer);
				featureBuffer.add(sexp);
				metaBuffer.clear();
				if (filterMatch(sexp)){
					featureOk = true;
				}
			}
			else{
				scenarioBuffer.add(sexp);
				scenarioOk |= filterMatch(scenarioBuffer);
				tableState = TableState.STEP;
			}
		}
		replayBuffersIfAllOk();
	}

	@Override
	public void row(List<String> row, int line) throws Exception {
		if (hasNoFilters()){
			listener.row(row, line);
		}
		else{
			Sexp sexp = new Sexp(Sexp.Events.ROW, row, line);
			if (tableState.equals(TableState.EXAMPLES)){
				if (!headerRowAllreadyBuffered()){
					examplesBuffer.add(sexp);
					if (filterMatch(examplesBuffer)){
						examplesOk = true;
					}
				}
				else{
					if (scenarioOk || examplesOk || featureOk || filterMatch(sexp)){
						examplesRowsBuffer.add(sexp);
					}
				}
			}
			else if (tableState.equals(TableState.STEP)){
				scenarioBuffer.add(sexp);
				scenarioOk |= filterMatch(scenarioBuffer);
			}
			else if (tableState.equals(TableState.BACKGROUND)){
				featureBuffer.addAll(metaBuffer);
				featureBuffer.add(sexp);
				metaBuffer.clear();
			}
			else{
				throw new RuntimeException("Bad table_state:" + tableState);
			}
		}
		replayBuffersIfAllOk();
	}

	@Override
	public void py_string(String string, int line) throws Exception {
		if (hasNoFilters()){
			listener.py_string(string, line);
		}
		else{
			scenarioBuffer.add(new Sexp(Sexp.Events.PY_STRING, string, line));
			scenarioOk |= filterMatch(scenarioBuffer);
		}
		replayBuffersIfAllOk();
	}

	@Override
	public void eof() throws Exception {
		replayExamplesRowsBuffer();
		listener.eof();
	}

	@Override
	public void syntax_error(String state, String event,
			List<String> legalEvents, int line) throws Exception {
	}

	private void detectFilters(List filters) {
		if (hasNoFilters()){
			return;
		}
		checkIfMoreThanOneFilterType(filters);
		this.filterMethod = new FilterMethodFactory().getFilterMethod(filters.get(0).getClass());
		this.filterMethod.setFilters(filters);
	}

	private void checkIfMoreThanOneFilterType(List filters) {
		Set<Class> filterTypes = new HashSet<Class>();
		for (Object object : filters) {
			filterTypes.add(object.getClass());
		}
		if (filterTypes.size() > 1){
			throw new RuntimeException("Bad Filter: " + filterTypes);
		}
	}

	private boolean hasNoFilters() {
		return filters.size() == 0;
	}

	private boolean headerRowAllreadyBuffered() {
		if (examplesBuffer.isEmpty()){
			return false;
		}
		return examplesBuffer.get(0).getEvent() == Sexp.Events.ROW;
	}

	private boolean filterMatch(Sexp sexp) {
		return filterMatch(Arrays.asList(sexp));
	}

	private boolean filterMatch(List<Sexp> buffer) {
		for (Sexp sexp : buffer) {
			if (filterMethod.filter(sexp)){
				return true;
			}
		}
		return false;
	}

	private boolean tagMatch() {
		if (filterMethod.getClass() != TagFilterMethod.class){
			return false;
		}
		return filterMethod.filterTags(currentTags());
	}

	private void replayBuffers() throws Exception {
		List<Sexp> allItems = new ArrayList<Sexp>();
		allItems.addAll(featureBuffer);
		allItems.addAll(scenarioBuffer);
		for (Sexp item : allItems) {
			System.out.println("Replay: " + item);
			item.replay(listener);
		}
		featureBuffer.clear();
		scenarioBuffer.clear();
	}

	private List<String> extractTags() {
		List<String> retVal = new ArrayList<String>();
		for (Sexp sexp : metaBuffer) {
			if (sexp.getEvent() == Sexp.Events.TAG){;
				retVal.add(sexp.getKeyword());
			}
		}
		return retVal;
	}

	private void replayExamplesRowsBuffer() throws Exception {
		if (!examplesRowsBuffer.isEmpty()){
			replayBuffers();
			List<Sexp> exampleItems = new ArrayList<Sexp>();
			exampleItems.addAll(examplesBuffer);
			exampleItems.addAll(examplesRowsBuffer);
			for (Sexp sexp : exampleItems) {
				System.out.println("replayExamplesRowsBuffer: " + sexp);
				sexp.replay(listener);
			}
			examplesRowsBuffer.clear();
		}
	}

	private void replayBuffersIfAllOk() throws Exception {
		if (scenarioOk || examplesOk || featureOk){
			System.out.println("replayBuffersIfAllOk");
			replayBuffers();
		}
	}

	private List currentTags() {
		List retVal = new ArrayList();
		retVal.addAll(featureTags);
		retVal.addAll(scenarioTags);
		retVal.addAll(exampleTags);
		return retVal;
	}

}
