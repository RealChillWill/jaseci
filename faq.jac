node faq_root;
node faq_state {
    has question;
    has answer;
}

graph faq {
    has anchor faq_root; // spawning a graph will return its anchor node (required for every graph)
    spawn {
        // spawning the nodes
        faq_root = spawn node::faq_root;
        faq_answer_1 = spawn node::faq_state (
            question = "How do I configure my order?",
            answer = "To configure your order, log into your Tesla account."
        );
        faq_answer_2 = spawn node::faq_state (
            question = "How do I order a Tesla?",
            answer = "Visit our design studio to place your order."
        );
        faq_answer_3 = spawn node::faq_state (
            question = "Can I request a test drive?",
            answer = "Yes. You must be a minimum of 25 years of age."
        );

        // connecting the nodes together
        faq_root ++> faq_answer_1; // ++> creates an edge
        faq_root ++> faq_answer_2; // --> references an edge
        faq_root ++> faq_answer_3;
    }
}

// when we run jac code, the init walker is being executed by default.
// kinda like int main() in C++.
walker init {
    root {
        spawn here ++> graph::faq; // 'here' always evaluates to the specific node the walker is currently on
        spawn here walker::ingest_faq(kb_file="tesla_faq.json");
        spawn here walker::ask;
    }
}

walker ask {
    can use.qa_classify;
    has question; // 'has' define variables
    root {
        question = std.input("AMA > "); // reads from command line
        take --> node::faq_root; // redirects to faq_root
    }
    faq_root {
        answers = -->.answer; // collects the answer variable of all of the 
                              // nodes that are connected to here/faq_root
        best_answer = use.qa_classify(
            text = question,
            classes = answers
        );
        // find the most relevant faq_state and then traverse 
        // to that node via a take statement
        take --> node::faq_state(question == question); 
        take --> node::faq_state(answer==best_answer["match"]);
    }
    faq_state {
        std.out(here.answer); // prints to command line
    }
}

walker ingest_faq {
    has kb_file;
    root: take --> node::faq_root;
    faq_root {
        kb = file.load_json(kb_file);
        for faq in kb {
            answer = faq["answer"];
            spawn here ++> node::faq_state(answer=answer);
        }
    }
}